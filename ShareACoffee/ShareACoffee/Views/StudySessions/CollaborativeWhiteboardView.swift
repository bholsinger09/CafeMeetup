import SwiftUI

/// Collaborative Whiteboard - Real-time drawing canvas for study groups
struct CollaborativeWhiteboardView: View {
    @ObservedObject var viewModel: WhiteboardViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStroke: WhiteboardStroke?
    @State private var selectedColor: Color = .black
    @State private var lineWidth: Double = 3.0
    @State private var showTools: Bool = true
    
    let availableColors: [Color] = [.black, .red, .blue, .green, .orange, .purple, .pink]
    let availableWidths: [Double] = [2.0, 3.0, 5.0, 8.0]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: viewModel.backgroundColor)
                    .ignoresSafeArea()
                
                // Canvas - Draw area
                Canvas { context, size in
                    // Draw all existing strokes
                    for stroke in viewModel.strokes {
                        if stroke.points.count > 1 {
                            var path = Path()
                            path.move(to: stroke.points[0].cgPoint)
                            
                            for point in stroke.points.dropFirst() {
                                path.addLine(to: point.cgPoint)
                            }
                            
                            context.stroke(
                                path,
                                with: .color(Color(hex: stroke.color)),
                                lineWidth: stroke.lineWidth
                            )
                        }
                    }
                    
                    // Draw current stroke being drawn
                    if let currentStroke = currentStroke, currentStroke.points.count > 1 {
                        var path = Path()
                        path.move(to: currentStroke.points[0].cgPoint)
                        
                        for point in currentStroke.points.dropFirst() {
                            path.addLine(to: point.cgPoint)
                        }
                        
                        context.stroke(
                            path,
                            with: .color(Color(hex: currentStroke.color)),
                            lineWidth: currentStroke.lineWidth
                        )
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let point = CGPointCodable(value.location)
                            
                            if currentStroke == nil {
                                // Start new stroke
                                currentStroke = WhiteboardStroke(
                                    userId: viewModel.currentUserId,
                                    userName: viewModel.currentUserName,
                                    points: [point],
                                    color: selectedColor.toHex(),
                                    lineWidth: lineWidth
                                )
                            } else {
                                // Add point to current stroke
                                currentStroke?.points.append(point)
                            }
                        }
                        .onEnded { _ in
                            // Finish stroke and sync to Firebase
                            if let stroke = currentStroke {
                                viewModel.addStroke(stroke)
                            }
                            currentStroke = nil
                        }
                )
                
                // Toolbar overlay
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: { withAnimation { showTools.toggle() } }) {
                            Image(systemName: showTools ? "chevron.up.circle.fill" : "paintbrush.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                    
                    if showTools {
                        toolbarContent
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                
                // Active participants indicator
                if !viewModel.activeParticipants.isEmpty {
                    VStack {
                        Spacer()
                        activeParticipantsView
                            .padding()
                    }
                }
            }
            .navigationTitle("Whiteboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.clearWhiteboard()
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
    
    private var toolbarContent: some View {
        VStack(spacing: 16) {
            // Color picker
            HStack(spacing: 12) {
                Text("Color:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(availableColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            
            // Line width picker
            HStack(spacing: 12) {
                Text("Size:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(availableWidths, id: \.self) { width in
                    Circle()
                        .fill(selectedColor)
                        .frame(width: width * 4, height: width * 4)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: lineWidth == width ? 2 : 0)
                        )
                        .onTapGesture {
                            lineWidth = width
                        }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.95))
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding(.horizontal)
    }
    
    private var activeParticipantsView: some View {
        HStack(spacing: -8) {
            ForEach(Array(viewModel.activeParticipants.prefix(5)), id: \.self) { participantName in
                Circle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(participantName.prefix(1).uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            
            if viewModel.activeParticipants.count > 5 {
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("+\(viewModel.activeParticipants.count - 5)")
                            .font(.caption2)
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 4)
    }
}

// MARK: - ViewModel

class WhiteboardViewModel: ObservableObject {
    @Published var strokes: [WhiteboardStroke] = []
    @Published var backgroundColor: String = "#FFFFFF"
    @Published var activeParticipants: [String] = []
    
    let currentUserId: String
    let currentUserName: String
    let studySessionId: String
    
    private let liveSessionService = LiveSessionService.shared
    
    init(studySessionId: String, userId: String, userName: String) {
        self.studySessionId = studySessionId
        self.currentUserId = userId
        self.currentUserName = userName
        
        setupRealtimeListeners()
    }
    
    func setupRealtimeListeners() {
        // Listen for whiteboard updates from Firebase
        liveSessionService.observeWhiteboardState(sessionId: studySessionId) { [weak self] state in
            DispatchQueue.main.async {
                self?.strokes = state.strokes
                self?.backgroundColor = state.backgroundColor
            }
        }
        
        // Listen for active participants
        liveSessionService.observeActiveParticipants(sessionId: studySessionId) { [weak self] participants in
            DispatchQueue.main.async {
                self?.activeParticipants = participants
            }
        }
    }
    
    func addStroke(_ stroke: WhiteboardStroke) {
        strokes.append(stroke)
        
        // Sync to Firebase
        liveSessionService.addWhiteboardStroke(sessionId: studySessionId, stroke: stroke) { success in
            print("Stroke synced: \(success)")
        }
    }
    
    func clearWhiteboard() {
        strokes.removeAll()
        
        // Sync to Firebase
        liveSessionService.clearWhiteboard(sessionId: studySessionId) { success in
            print("Whiteboard cleared: \(success)")
        }
    }
}

// MARK: - Color Extensions

extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    CollaborativeWhiteboardView(
        viewModel: WhiteboardViewModel(
            studySessionId: "session123",
            userId: "user1",
            userName: "John Doe"
        )
    )
}
