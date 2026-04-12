//  ARCafeAnnotationNode.swift
//  ShareACoffee
//
//  AR visualization nodes for cafe navigation
//  Note: SCNNode has unfixable actor isolation conflicts in iOS SDK as of Swift 6.0
//  Using async Task initialization to work around framework limitations

import Foundation
@preconcurrency import ARKit
@preconcurrency import SceneKit
@preconcurrency import UIKit

/// AR Annotation Node - Enhanced 3D markers with info overlays for cafes
class ARCafeAnnotationNode: SCNNode {
    let cafe: ARCafeLocation
    private var infoCardNode: SCNNode?
    private var pulseAnimation: CAAnimation?
    
    init(cafe: ARCafeLocation) {
        self.cafe = cafe
        super.init()
        Task { @MainActor in
            self.setupNode()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    private func setupNode() {
        // Create main marker
        let markerNode = createMarker()
        addChildNode(markerNode)
        
        // Create info card
        let cardNode = createInfoCard()
        cardNode.position = SCNVector3(0, 0.8, 0)
        addChildNode(cardNode)
        infoCardNode = cardNode
        
        // Add billboard constraint to always face camera
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = [.Y]
        constraints = [constraint]
        
        // Add pulse animation
        addPulseAnimation()
    }
    
    @MainActor
    private func createMarker() -> SCNNode {
        let node = SCNNode()
        
        // Main cone marker
        let coneGeometry = SCNCone(topRadius: 0, bottomRadius: 0.15, height: 0.4)
        let coneMaterial = SCNMaterial()
        coneMaterial.diffuse.contents = getMarkerColor()
        coneMaterial.emission.contents = getMarkerColor().withAlphaComponent(0.5)
        coneGeometry.materials = [coneMaterial]
        
        let coneNode = SCNNode(geometry: coneGeometry)
        coneNode.position = SCNVector3(0, 0.2, 0)
        node.addChildNode(coneNode)
        
        // Base circle
        let cylinderGeometry = SCNCylinder(radius: 0.2, height: 0.05)
        let cylinderMaterial = SCNMaterial()
        cylinderMaterial.diffuse.contents = getMarkerColor().withAlphaComponent(0.7)
        cylinderGeometry.materials = [cylinderMaterial]
        
        let cylinderNode = SCNNode(geometry: cylinderGeometry)
        cylinderNode.position = SCNVector3(0, 0.025, 0)
        node.addChildNode(cylinderNode)
        
        return node
    }
    
    @MainActor
    private func createInfoCard() -> SCNNode {
        let cardNode = SCNNode()
        
        // Create card background
        let cardWidth: CGFloat = 1.2
        let cardHeight: CGFloat = 0.6
        
        let cardPlane = SCNPlane(width: cardWidth, height: cardHeight)
        let cardMaterial = SCNMaterial()
        
        // Create UIView for card content
        let cardView = createCardView(width: cardWidth * 400, height: cardHeight * 400)
        cardMaterial.diffuse.contents = cardView
        cardMaterial.isDoubleSided = false
        
        cardPlane.materials = [cardMaterial]
        cardNode.geometry = cardPlane
        
        // Add subtle shadow
        cardNode.castsShadow = true
        
        return cardNode
    }
    
    @MainActor
    private func createCardView(width: CGFloat, height: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 2
        view.layer.borderColor = getMarkerColor().cgColor
        
        // Cafe name
        let nameLabel = UILabel(frame: CGRect(x: 20, y: 20, width: width - 40, height: 60))
        nameLabel.text = cafe.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 40)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(nameLabel)
        
        // Distance
        let distanceLabel = UILabel(frame: CGRect(x: 20, y: 90, width: width - 40, height: 40))
        distanceLabel.text = "📍 \(Int(cafe.distance))m away"
        distanceLabel.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        distanceLabel.textColor = UIColor.systemBlue
        distanceLabel.textAlignment = .center
        view.addSubview(distanceLabel)
        
        // Info row
        let infoStackY: CGFloat = 140
        let infoWidth: CGFloat = (width - 60) / 3
        
        // Occupancy
        if cafe.currentOccupancy > 0 {
            let occupancyView = createInfoItem(
                icon: "👥",
                value: "\(cafe.currentOccupancy)",
                label: "Studying",
                frame: CGRect(x: 20, y: infoStackY, width: infoWidth, height: 80)
            )
            view.addSubview(occupancyView)
        }
        
        // Active sessions
        if cafe.activeSessionsCount > 0 {
            let sessionsView = createInfoItem(
                icon: "📚",
                value: "\(cafe.activeSessionsCount)",
                label: "Sessions",
                frame: CGRect(x: 20 + infoWidth + 10, y: infoStackY, width: infoWidth, height: 80)
            )
            view.addSubview(sessionsView)
        }
        
        // Direction
        if cafe.bearing != nil {
            let directionView = createInfoItem(
                icon: "🧭",
                value: cafe.directionDescription,
                label: "Direction",
                frame: CGRect(x: width - infoWidth - 20, y: infoStackY, width: infoWidth, height: 80)
            )
            view.addSubview(directionView)
        }
        
        return view
    }
    
    @MainActor
    private func createInfoItem(icon: String, value: String, label: String, frame: CGRect) -> UIView {
        let container = UIView(frame: frame)
        
        let iconLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        container.addSubview(iconLabel)
        
        let valueLabel = UILabel(frame: CGRect(x: 0, y: 30, width: frame.width, height: 25))
        valueLabel.text = value
        valueLabel.font = UIFont.boldSystemFont(ofSize: 22)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        container.addSubview(valueLabel)
        
        let labelText = UILabel(frame: CGRect(x: 0, y: 55, width: frame.width, height: 20))
        labelText.text = label
        labelText.font = UIFont.systemFont(ofSize: 16)
        labelText.textColor = UIColor.lightGray
        labelText.textAlignment = .center
        container.addSubview(labelText)
        
        return container
    }
    
    @MainActor
    private func getMarkerColor() -> UIColor {
        // Color based on distance and occupancy
        if cafe.distance < 100 {
            return .systemGreen // Very close
        } else if cafe.currentOccupancy > 10 {
            return .systemRed // Busy
        } else if cafe.activeSessionsCount > 0 {
            return .systemBlue // Has active sessions
        } else {
            return .systemOrange // Default
        }
    }
    
    @MainActor
    private func addPulseAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "scale")
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = SCNVector3(1, 1, 1)
        pulseAnimation.toValue = SCNVector3(1.1, 1.1, 1.1)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        
        addAnimation(pulseAnimation, forKey: "pulse")
    }
    
    @MainActor
    func updateVisibility(isVisible: Bool) {
        opacity = isVisible ? 1.0 : 0.3
    }
    
    @MainActor
    func highlight() {
        // Add highlight effect
        let highlightAnimation = CABasicAnimation(keyPath: "opacity")
        highlightAnimation.duration = 0.3
        highlightAnimation.fromValue = 1.0
        highlightAnimation.toValue = 0.5
        highlightAnimation.autoreverses = true
        highlightAnimation.repeatCount = 3
        
        addAnimation(highlightAnimation, forKey: "highlight")
    }
}

/// AR Direction Arrow - Floating arrow that points to selected cafe
class ARDirectionArrowNode: SCNNode {
    private let targetCafe: ARCafeLocation
    private var arrowNode: SCNNode?
    
    init(targetCafe: ARCafeLocation) {
        self.targetCafe = targetCafe
        super.init()
        Task { @MainActor in
            self.setupArrow()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    private func setupArrow() {
        // Create arrow shape
        let arrowPath = createArrowPath()
        let arrowShape = SCNShape(path: arrowPath, extrusionDepth: 0.05)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemGreen
        material.emission.contents = UIColor.systemGreen.withAlphaComponent(0.5)
        arrowShape.materials = [material]
        
        let arrow = SCNNode(geometry: arrowShape)
        arrow.position = SCNVector3(0, 0, -1.5) // 1.5m in front of user
        addChildNode(arrow)
        arrowNode = arrow
        
        // Add floating animation
        addFloatingAnimation()
    }
    
    @MainActor
    private func createArrowPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        // Arrow shaft
        path.move(to: CGPoint(x: -0.05, y: 0))
        path.addLine(to: CGPoint(x: -0.05, y: 0.3))
        path.addLine(to: CGPoint(x: 0.05, y: 0.3))
        path.addLine(to: CGPoint(x: 0.05, y: 0))
        
        // Arrow head
        path.move(to: CGPoint(x: -0.15, y: 0.3))
        path.addLine(to: CGPoint(x: 0, y: 0.5))
        path.addLine(to: CGPoint(x: 0.15, y: 0.3))
        path.close()
        
        return path
    }
    
    @MainActor
    private func addFloatingAnimation() {
        let floatAnimation = CABasicAnimation(keyPath: "position.y")
        floatAnimation.duration = 2.0
        floatAnimation.fromValue = 0
        floatAnimation.toValue = 0.2
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        
        arrowNode?.addAnimation(floatAnimation, forKey: "float")
    }
    
    @MainActor
    func updateDirection(bearing: Double, currentHeading: Double) {
        let angle = (bearing - currentHeading) * .pi / 180.0
        eulerAngles = SCNVector3(0, Float(-angle), 0)
    }
}

/// AR Occupancy Heatmap - Visual overlay showing cafe occupancy levels
class AROccupancyHeatmapNode: SCNNode {
    private let cafes: [ARCafeLocation]
    
    init(cafes: [ARCafeLocation]) {
        self.cafes = cafes
        super.init()
        Task { @MainActor in
            self.createHeatmap()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    private func createHeatmap() {
        for cafe in cafes where cafe.currentOccupancy > 0 {
            let heatNode = createHeatCircle(for: cafe)
            addChildNode(heatNode)
        }
    }
    
    @MainActor
    private func createHeatCircle(for cafe: ARCafeLocation) -> SCNNode {
        let radius = 0.3 + (Float(cafe.currentOccupancy) * 0.02) // Radius based on occupancy
        let circle = SCNPlane(width: CGFloat(radius * 2), height: CGFloat(radius * 2))
        
        // Create gradient material
        let material = SCNMaterial()
        material.diffuse.contents = createHeatGradient(occupancy: cafe.currentOccupancy)
        material.transparency = 0.6
        material.isDoubleSided = false
        
        circle.materials = [material]
        
        let node = SCNNode(geometry: circle)
        node.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0) // Lay flat on ground
        
        return node
    }
    
    @MainActor
    private func createHeatGradient(occupancy: Int) -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    getOccupancyColor(occupancy).withAlphaComponent(0.8).cgColor,
                    getOccupancyColor(occupancy).withAlphaComponent(0.0).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }
    }
    
    @MainActor
    private func getOccupancyColor(_ occupancy: Int) -> UIColor {
        switch occupancy {
        case 0...3: return .systemGreen
        case 4...7: return .systemYellow
        case 8...12: return .systemOrange
        default: return .systemRed
        }
    }
}
