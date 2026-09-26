import SwiftUI
import ShareACoffeeCore
import ShareACoffeeAuth
import ShareACoffeeStudy
import ShareACoffeeCoffee
import ShareACoffeeSocial
import ShareACoffeeBlog
import ShareACoffeeDiscovery
import ShareACoffeeProfile
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
            
            makeCameraOverlay()
            makeSuccessOverlay()
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
    
    @ViewBuilder
    private func makeCameraOverlay() -> some View {
        VStack {
            makeTopGradient()
            Spacer()
            makeScanningFrame()
            Spacer()
            makeInstructionsView()
        }
    }
    
    @ViewBuilder
    private func makeTopGradient() -> some View {
        LinearGradient(
            colors: [.black.opacity(0.5), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 100)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func makeScanningFrame() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 3)
                .frame(width: 280, height: 280)
            
            if viewModel.isScanning {
                makeScanningLine()
            }
            
            ForEach(0..<4) { index in
                cornerBracket()
                    .rotationEffect(.degrees(Double(index) * 90))
                    .offset(
                        x: index % 2 == 0 ? -140 : 140,
                        y: index < 2 ? -140 : 140
                    )
            }
        }
    }
    
    @ViewBuilder
    private func makeInstructionsView() -> some View {
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
    
    @ViewBuilder
    private func makeSuccessOverlay() -> some View {
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
                    let displayName = scannedData.name ?? "QR Code"
                    Text(displayName)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeScanningLine() -> some View {
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
                
                Text(qrData.name ?? "QR Code")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Data:")
                            .foregroundColor(.secondary)
                        Text(qrData.rawData)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Text("Type:")
                            .foregroundColor(.secondary)
                        Text(typeDescription(qrData.type))
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Time:")
                            .foregroundColor(.secondary)
                        Text(qrData.timestamp.formatted())
                            .fontWeight(.medium)
                            .font(.caption)
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
    private func iconForType(_ type: String?) -> some View {
        Image(systemName: "qrcode")
    }
    
    private func gradientColors(for type: String?) -> [Color] {
        return [.blue, .purple]
    }
    
    private func typeDescription(_ type: QRCodeService.QRCodeType) -> String {
        switch type {
        case .sessionJoin: return "Session Join"
        case .userProfile: return "User Profile"
        case .coffeeShop: return "Coffee Shop"
        case .other: return "Other"
        }
    }
    
    @ViewBuilder
    private func actionButton(for data: QRCodeService.QRCodeData) -> some View {
        if let codeType = data.codeType, codeType == "studySession" {
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
        } else {
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
    
    private func checkCameraPermission(completion: @escaping @Sendable (Bool) -> Void) {
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
        guard let qrData = QRCodeService.shared.parseQRCode(code) else {
            errorMessage = "Invalid QR code format"
            return
        }
        
        // Validate QR code
        guard QRCodeService.shared.isQRCodeValid(code) else {
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
        /*
        let qrData = QRCodeService.QRCodeData(
            type: QRCodeService.QRCodeType.sessionJoin(sessionId),
            rawData: sessionId,
            name: "Study Session"
        )
        
        scannedData = qrData
        */
    }
}
