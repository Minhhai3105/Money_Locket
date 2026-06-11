import SwiftUI
import Combine
import AVFoundation

class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var capturedImage: UIImage? = nil
    @Published var isSessionRunning = false
    @Published var zoomFactor: CGFloat = 1.0 {
        didSet {
            setZoom(zoomFactor)
        }
    }
    
    private var videoInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "money.locket.camera.sessionQueue")
    
    override init() {
        super.init()
        checkPermissionsAndSetup()
    }
    
    func checkPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCamera()
                }
            }
        default:
            // Fallback for Simulator or Denied permissions
            self.setupSimulatorMock()
        }
    }
    
    private func setupCamera() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            // Choose dual camera or standard back camera
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                self.session.commitConfiguration()
                self.setupSimulatorMock()
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.videoInput = input
                }
                
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                
                self.session.commitConfiguration()
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = self.session.isRunning
                }
            } catch {
                self.session.commitConfiguration()
                self.setupSimulatorMock()
            }
        }
    }
    
    private func setupSimulatorMock() {
        print("Using Simulator/Mock Mode for Camera feed.")
        DispatchQueue.main.async {
            self.isSessionRunning = false
        }
    }
    
    func capturePhoto() {
        #if targetEnvironment(simulator)
        simulateCapture()
        #else
        guard session.isRunning else {
            simulateCapture() // fallback for simulator or devices without permission
            return
        }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        #endif
    }
    
    private func simulateCapture() {
        // Generates a mock color or patterns with text placeholder
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 600))
        let mockImg = renderer.image { ctx in
            // Draw a nice modern gradient background
            let colors = [UIColor.systemYellow.cgColor, UIColor.systemOrange.cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil)!
            ctx.cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 600, y: 600), options: [])
            
            // Draw text overlay
            let text = "Money Locket Live"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 42),
                .foregroundColor: UIColor.white
            ]
            let stringSize = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: (600 - stringSize.width)/2, y: (600 - stringSize.height)/2), withAttributes: attrs)
        }
        
        DispatchQueue.main.async {
            self.capturedImage = mockImg
        }
    }
    
    func resetCamera() {
        DispatchQueue.main.async {
            self.capturedImage = nil
        }
        if !session.isRunning {
            sessionQueue.async {
                self.session.startRunning()
            }
        }
    }
    
    private func setZoom(_ factor: CGFloat) {
        guard let device = videoInput?.device else { return }
        do {
            try device.lockForConfiguration()
            // Support 1x to 3x zoom safely
            let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 3.0)
            let finalFactor = min(max(factor, 1.0), maxZoom)
            device.videoZoomFactor = finalFactor
            device.unlockForConfiguration()
        } catch {
            print("Failed to lock configuration for zoom: \(error)")
        }
    }
    
    func sendSocialOnly() {
        // Simulate uploading capturedImage as social only locket post
        print("Sending social only photo to friends' lockets...")
        resetCamera()
    }
    
    func saveTransaction(amount: Double, category: String, notes: String, type: TransactionType) {
        // In full app, upload image to storage and save metadata to Database
        let formattedType = type == .income ? "Income" : "Expense"
        print("Saved transaction: \(formattedType) of \(amount) VND under category '\(category)' with note '\(notes)'")
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Capture failed: \(error.localizedDescription)")
            return
        }
        
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}
