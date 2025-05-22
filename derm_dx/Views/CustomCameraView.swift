import SwiftUI
import AVFoundation

struct CustomCameraView: View {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var cameraModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(session: cameraModel.session)
                .ignoresSafeArea()
            
            // Overlay with just the square guide (no grey areas)
            GeometryReader { geometry in
                ZStack {
                    // Calculate the square size
                    let squareSize = min(geometry.size.width, geometry.size.height) * 0.8
                    
                    // Border for the square guide
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: squareSize, height: squareSize)
                    
                    // Instruction text at the top
                    VStack {
                        Text("Position the lesion in the square")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                            .padding(.top, 50)
                        
                        Spacer()
                    }
                    
                    // Capture button at the bottom
                    VStack {
                        Spacer()
                        HStack {
                            // Close button
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title)
                                    .padding()
                                    .background(Circle().fill(Color.black.opacity(0.7)))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Capture button
                            Button(action: {
                                // Just capture the photo without cropping
                                cameraModel.capturePhoto { photo in
                                    if let photo = photo {
                                        image = photo
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.8), lineWidth: 2)
                                            .frame(width: 60, height: 60)
                                    )
                            }
                            
                            Spacer()
                            
                            // Flip camera button
                            Button(action: {
                                cameraModel.flipCamera()
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .font(.title)
                                    .padding()
                                    .background(Circle().fill(Color.black.opacity(0.7)))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear {
            cameraModel.checkPermissions()
        }
    }
}

// Camera preview view
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Camera view model to handle camera operations
class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var isCaptureSessionConfigured = false
    private var currentCamera: AVCaptureDevice?
    private var captureCompletion: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                }
            }
        default:
            break
        }
    }
    
    func setupCaptureSession() {
        guard !isCaptureSessionConfigured else { return }
        
        session.beginConfiguration()
        
        // Add video input
        guard let camera = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(videoInput) else {
            return
        }
        
        currentCamera = camera
        session.addInput(videoInput)
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
        isCaptureSessionConfigured = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        captureCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func flipCamera() {
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        // Toggle between front and back camera
        let newPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
        
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newCamera),
              session.canAddInput(newInput) else {
            // If the new camera can't be added, add the current one back
            session.addInput(currentInput)
            session.commitConfiguration()
            return
        }
        
        currentCamera = newCamera
        session.addInput(newInput)
        session.commitConfiguration()
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), 
              let image = UIImage(data: data) else {
            captureCompletion?(nil)
            return
        }
        
        // Return the full uncropped image
        captureCompletion?(image)
    }
} 