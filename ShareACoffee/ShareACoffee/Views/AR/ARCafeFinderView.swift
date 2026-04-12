import SwiftUI
import ARKit
import CoreLocation

/// AR Cafe Finder - Augmented reality navigation to nearby coffee shops
struct ARCafeFinderView: View {
    @StateObject private var viewModel: ARCafeFinderViewModel
    @Environment(\.dismiss) var dismiss
    
    init(cafes: [CoffeeShop], userLocation: CLLocationCoordinate2D) {
        _viewModel = StateObject(wrappedValue: ARCafeFinderViewModel(cafes: cafes, userLocation: userLocation))
    }
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(viewModel: viewModel)
                .ignoresSafeArea()
            
            // Top controls overlay
            VStack {
                topControlsView
                
                Spacer()
                
                // Bottom info panel
                bottomInfoPanel
            }
            
            // Loading/Error states
            if viewModel.isLoading {
                loadingView
            }
            
            if let error = viewModel.errorMessage {
                errorView(message: error)
            }
        }
        .onAppear {
            viewModel.startARSession()
        }
        .onDisappear {
            viewModel.stopARSession()
        }
    }
    
    private var topControlsView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(viewModel.nearbyCafes.count) cafes nearby")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                if viewModel.isARSupported {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        
                        Text("AR Active")
                            .font(.caption2)
                    }
                } else {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text("AR Not Available")
                            .font(.caption2)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(12)
        }
        .padding()
    }
    
    private var bottomInfoPanel: some View {
        VStack(spacing: 0) {
            // Selected cafe info (if any)
            if let selectedCafe = viewModel.selectedCafe {
                selectedCafeView(cafe: selectedCafe)
                    .transition(.move(edge: .bottom))
            }
            
            // Cafe list
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.nearbyCafes) { cafe in
                        cafeCardView(cafe: cafe)
                            .onTapGesture {
                                viewModel.selectCafe(cafe)
                            }
                    }
                }
                .padding()
            }
            .frame(height: 140)
            .background(Color.black.opacity(0.8))
        }
    }
    
    private func selectedCafeView(cafe: ARCafeLocation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(cafe.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Label("\(String(format: "%.0f", cafe.distance))m", systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        if cafe.currentOccupancy > 0 {
                            Label("\(cafe.currentOccupancy) studying", systemImage: "person.2.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        if cafe.activeSessionsCount > 0 {
                            Label("\(cafe.activeSessionsCount) sessions", systemImage: "book.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
                
                Button(action: { viewModel.navigateToCafe(cafe) }) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            // Direction indicator
            if cafe.bearing != nil {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                    
                    Text(cafe.directionDescription)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.8))
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
    
    private func cafeCardView(cafe: ARCafeLocation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(cafe.isVisible ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                
                Text(cafe.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            
            Text("\(String(format: "%.0f", cafe.distance))m away")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            
            if cafe.currentOccupancy > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                    
                    Text("\(cafe.currentOccupancy)")
                        .font(.caption2)
                }
                .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .frame(width: 100, height: 80)
        .padding(8)
        .background(viewModel.selectedCafe?.id == cafe.id ? Color.blue.opacity(0.6) : Color.white.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Initializing AR...")
                .foregroundColor(.white)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.7))
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            
            Text(message)
                .foregroundColor(.white)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Dismiss") {
                viewModel.clearError()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
        .padding()
    }
}

// MARK: - ARView Container

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARCafeFinderViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator
        
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = []
        
        arView.session.run(configuration)
        
        // Store reference
        viewModel.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update AR annotations when cafe list changes
        context.coordinator.updateAnnotations()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    @MainActor
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        let viewModel: ARCafeFinderViewModel
        private var annotationNodes: [String: SCNNode] = [:]
        
        init(viewModel: ARCafeFinderViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        func updateAnnotations() {
            guard let arView = viewModel.arView else { return }
            
            // Remove old annotations
            for (_, node) in annotationNodes {
                node.removeFromParentNode()
            }
            annotationNodes.removeAll()
            
            // Add new annotations
            for cafe in viewModel.nearbyCafes {
                addAnnotation(for: cafe, in: arView)
            }
        }
        
        private func addAnnotation(for cafe: ARCafeLocation, in arView: ARSCNView) {
            // Create annotation node
            let node = createCafeAnnotationNode(cafe: cafe)
            
            // Calculate position based on location
            if let position = viewModel.calculateARPosition(for: cafe) {
                node.position = position
                arView.scene.rootNode.addChildNode(node)
                annotationNodes[cafe.id] = node
            }
        }
        
        private func createCafeAnnotationNode(cafe: ARCafeLocation) -> SCNNode {
            let node = SCNNode()
            
            // Create a vertical arrow/marker
            let arrowGeometry = createArrowGeometry()
            let arrowNode = SCNNode(geometry: arrowGeometry)
            arrowNode.position = SCNVector3(0, 0, 0)
            node.addChildNode(arrowNode)
            
            // Add text label
            if let textGeometry = createTextGeometry(text: cafe.name) {
                let textNode = SCNNode(geometry: textGeometry)
                textNode.position = SCNVector3(0, 0.5, 0)
                node.addChildNode(textNode)
            }
            
            // Add distance label
            if let distanceGeometry = createTextGeometry(text: "\(Int(cafe.distance))m") {
                let distanceNode = SCNNode(geometry: distanceGeometry)
                distanceNode.position = SCNVector3(0, 0.3, 0)
                distanceNode.scale = SCNVector3(0.5, 0.5, 0.5)
                node.addChildNode(distanceNode)
            }
            
            // Make node always face camera
            let constraint = SCNBillboardConstraint()
            constraint.freeAxes = [.Y]
            node.constraints = [constraint]
            
            return node
        }
        
        private func createArrowGeometry() -> SCNGeometry {
            // Create a cone that points upward
            let cone = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.3)
            cone.firstMaterial?.diffuse.contents = UIColor.systemBlue
            cone.firstMaterial?.emission.contents = UIColor.systemBlue.withAlphaComponent(0.5)
            return cone
        }
        
        private func createTextGeometry(text: String) -> SCNGeometry? {
            let textGeometry = SCNText(string: text, extrusionDepth: 0.01)
            textGeometry.font = UIFont.systemFont(ofSize: 0.1, weight: .bold)
            textGeometry.firstMaterial?.diffuse.contents = UIColor.white
            textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            textGeometry.truncationMode = CATextLayerTruncationMode.middle.rawValue
            textGeometry.containerFrame = CGRect(x: -0.5, y: 0, width: 1.0, height: 0.2)
            return textGeometry
        }
        
        // MARK: - ARSessionDelegate
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Update cafe visibility based on camera position
            viewModel.updateCafeVisibility(cameraTransform: frame.camera.transform)
        }
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            viewModel.handleARError(error)
        }
    }
}

// MARK: - Helper Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ARCafeFinderView(
        cafes: [
            CoffeeShop(
                id: "1",
                name: "Starbucks Downtown",
                address: "123 Main St",
                city: "Boston",
                state: "MA",
                zipCode: "02101",
                location: Location(latitude: 42.3601, longitude: -71.0589),
                rating: 4.5,
                amenities: []
            )
        ],
        userLocation: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
    )
}
