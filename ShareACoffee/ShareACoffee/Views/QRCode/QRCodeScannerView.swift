import SwiftUI
import AVFoundation
import Combine

/// QR Code Scanner View - Scan QR codes to join sessions or check into cafes
struct QRCodeScannerView: View {
    @StateObject private var viewModel = QRCodeScannerViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            scannerContent
        }
    }
    
    private var scannerContent: some View {
            ZStack {
                // Camera preview
                QRCodeCameraView(viewModel: viewModel)
                    .ignoresSafeArea()
                
                // Overlay UI
                VStack {
                    // Top gradient for readability
                    LinearGradient(
                        colors: [.black.opacity(0.5), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .ignoresSafeArea()
                    
                    Spacer()
                    
                    // Scanning frame
                    ZStack {
                        // Corner brackets
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 280, height: 280)
                        
                        // Animated scanning line
                        if viewModel.isScanning {
                            scanningLine
                        }
                        
                        // Corner decorations
                        ForEach(0..<4) { index in
                            cornerBracket()
                                .rotationEffect(.degrees(Double(index) * 90))
                                .offset(
                                    x: index % 2 == 0 ? -140 : 140,
                                    y: index < 2 ? -140 : 140
                                )
                        }
                    }
                    
                    Spacer()
                    
                    // Instructions
                    VStack(spacing: 16) {
                        if viewModel.isScanning {
                            Text("Position QR code within the frame")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                        }
                        
                        // Manual entry option
                        Button(action: { viewModel.showManualEntry = true }) {
                            HStack {
                                Image(systemName: "keyboard")
                                Text("Enter Code Manually")
                            }
                            .font(.subheadline)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                // Success overlay
                if viewModel.scanSuccess {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("QR Code Scanned!")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        if let scannedData = viewModel.scannedData {
                            Text(scannedData.name)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Scan QR Code")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .alert("Camera Access Required", isPresented: $viewModel.showPermissionAlert) {
                Button("Open Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Please enable camera access in Settings to scan QR codes.")
            }
            .sheet(isPresented: $viewModel.showManualEntry) {
                ManualCodeEntryView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.scannedData) { qrData in
                QRCodeActionView(qrData: qrData, viewModel: viewModel)
            }
        }
    }
    
    private var scanningLine: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .blue, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 280, height: 2)
            .offset(y: viewModel.scanLineOffset)
    }
    
    private func cornerBracket() -> some View {
        ZStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 30, height: 4)
                .offset(x: -13, y: -13)
            
            Rectangle()
                .fill(Color.blue)
                .frame(width: 4, height: 30)
                .offset(x: -13, y: -13)
        }
    }

// MARK: - Camera View

struct QRCodeCameraView: UIViewRepresentable {
    @ObservedObject var viewModel: QRCodeScannerViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        viewModel.setupCamera(in: view)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Manual Entry View

struct ManualCodeEntryView: View {
    @ObservedObject var viewModel: QRCodeScannerViewModel
    @State private var codeInput = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter session code", text: $codeInput)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } header: {
                    Text("Session Code")
                } footer: {
                    Text("Enter the session code shared by the host")
                }
                
                Section {
                    Button(action: processManualCode) {
                        HStack {
                            Spacer()
                            Text("Join Session")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(codeInput.isEmpty)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func processManualCode() {
        // Try to parse as session ID
        viewModel.processManualSessionId(codeInput)
        dismiss()
    }
}

// MARK: - Action View

struct QRCodeActionView: View {
    let qrData: QRCodeService.QRCodeData
    @ObservedObject var viewModel: QRCodeScannerViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Icon based on type
                iconForType(qrData.codeType)
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors(for: qrData.codeType),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(qrData.name)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    if let details = qrData.details {
                        ForEach(Array(details.keys.sorted()), id: \.self) { key in
                            if let value = details[key] {
                                HStack {
                                    Text(key.capitalized + ":")
                                        .foregroundColor(.secondary)
                                    Text(value)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Action button
                actionButton(for: qrData)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
            .padding(.top, 40)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func iconForType(_ type: QRCodeService.QRCodeType?) -> some View {
        switch type {
        case .studySession:
            Image(systemName: "book.circle.fill")
        case .cafeCheckIn:
            Image(systemName: "cup.and.saucer.fill")
        case .arMarker:
            Image(systemName: "camera.viewfinder")
        case .none:
            Image(systemName: "qrcode")
        }
    }
    
    private func gradientColors(for type: QRCodeService.QRCodeType?) -> [Color] {
        switch type {
        case .studySession:
            return [.blue, .purple]
        case .cafeCheckIn:
            return [.brown, .orange]
        case .arMarker:
            return [.green, .blue]
        case .none:
            return [.gray, .secondary]
        }
    }
    
    @ViewBuilder
    private func actionButton(for data: QRCodeService.QRCodeData) -> some View {
        switch data.codeType {
        case .studySession:
            Button(action: { joinSession(data.id) }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Join Study Session")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
        case .cafeCheckIn:
            Button(action: { checkIntoCafe(data.id) }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Check In to Cafe")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.brown, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
        case .arMarker:
            Button(action: { openARExperience(data) }) {
                HStack {
                    Image(systemName: "arkit")
                    Text("Launch AR Experience")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
        case .none:
            EmptyView()
        }
    }
    
    // MARK: - Actions
    
    private func joinSession(_ sessionId: String) {
        // TODO: Implement session joining logic
        // This would typically:
        // 1. Fetch session details from Firebase
        // 2. Add user to attendees
        // 3. Navigate to LiveStudySessionView
        print("Joining session: \(sessionId)")
        dismiss()
    }
    
    private func checkIntoCafe(_ cafeId: String) {
        // TODO: Implement cafe check-in logic
        print("Checking into cafe: \(cafeId)")
        dismiss()
    }
    
    private func openARExperience(_ data: QRCodeService.QRCodeData) {
        // TODO: Implement AR experience launch
        print("Opening AR experience for: \(data.name)")
        dismiss()
    }
}

// MARK: - ViewModel

@MainActor
class QRCodeScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var isScanning = false
    @Published var scanSuccess = false
    @Published var scanLineOffset: CGFloat = -140
    @Published var errorMessage: String?
    @Published var showPermissionAlert = false
    @Published var showManualEntry = false
    @Published var scannedData: QRCodeService.QRCodeData?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupCamera(in view: UIView) {
        checkCameraPermission { [weak self] granted in
            guard let self = self else { return }
            
            Task { @MainActor in
                if granted {
                    self.configureCaptureSession(in: view)
                } else {
                    self.showPermissionAlert = true
                }
            }
        }
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }
    
    private func configureCaptureSession(in view: UIView) {
        let session = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              session.canAddInput(videoInput) else {
            errorMessage = "Unable to access camera"
            return
        }
        
        session.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            errorMessage = "Unable to configure camera"
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        self.captureSession = session
        self.previewLayer = previewLayer
        
        Task {
            session.startRunning()
            isScanning = true
            startScanAnimation()
        }
    }
    
    private func startScanAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            scanLineOffset = 140
        }
    }
    
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            return
        }
        
        Task { @MainActor in
            processQRCode(stringValue)
        }
    }
    
    private func processQRCode(_ code: String) {
        guard !scanSuccess else { return }
        
        // Parse QR code
        guard let qrData = QRCodeService.shared.parseQRCode(from: code) else {
            errorMessage = "Invalid QR code format"
            return
        }
        
        // Validate QR code
        guard QRCodeService.shared.isQRCodeValid(qrData) else {
            errorMessage = "This QR code has expired"
            return
        }
        
        // Success!
        scanSuccess = true
        isScanning = false
        captureSession?.stopRunning()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show action sheet after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scannedData = qrData
            self.scanSuccess = false
        }
    }
    
    func processManualSessionId(_ sessionId: String) {
        // Create minimal QR data for manual entry
        let qrData = QRCodeService.QRCodeData(
            type: QRCodeService.QRCodeType.studySession.rawValue,
            id: sessionId,
            name: "Study Session",
            details: nil,
            timestamp: Date()
        )
        
        scannedData = qrData
    }
}
