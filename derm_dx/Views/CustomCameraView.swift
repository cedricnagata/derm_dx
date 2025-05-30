import SwiftUI
import AVFoundation

struct CustomCameraView: View {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var cameraModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(session: cameraModel.session, cameraModel: cameraModel)
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
                            .padding(.top, 100)
                        
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
                    
                    // Macro mode button (only shown if available)
                    if cameraModel.isMacroAvailable {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    cameraModel.toggleMacroMode()
                                }) {
                                    VStack {
                                        Image(systemName: "camera.macro")
                                            .font(.callout)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .fill(cameraModel.isMacroEnabled ? Color.yellow : Color.black.opacity(0.7))
                                            )
                                            .foregroundColor(.white)
                                        
                                        Text("Macro")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(Color.black.opacity(0.6))
                                            .cornerRadius(4)
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.trailing, 15)
                            }
                            
                            Spacer()
                        }
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
    var cameraModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Add tap gesture recognizer for manual focus
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CameraPreview
        
        init(_ parent: CameraPreview) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let point = gesture.location(in: gesture.view)
            parent.cameraModel.focusOnPoint(point, in: gesture.view!)
            
            // Show focus animation
            if let view = gesture.view {
                let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
                focusView.layer.borderColor = UIColor.yellow.cgColor
                focusView.layer.borderWidth = 2
                focusView.center = point
                focusView.backgroundColor = .clear
                view.addSubview(focusView)
                
                UIView.animate(withDuration: 0.3, animations: {
                    focusView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                }) { _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        focusView.alpha = 0
                    }) { _ in
                        focusView.removeFromSuperview()
                    }
                }
            }
        }
    }
}

// Camera view model to handle camera operations
class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isMacroAvailable = false
    @Published var isMacroEnabled = false
    
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
        
        // Simple check for macro camera availability - if ultra-wide camera exists on Pro models
        isMacroAvailable = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) != nil
        
        // Add video input - start with back camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(videoInput) else {
            return
        }
        
        currentCamera = camera
        
        // Configure camera for autofocus
        do {
            try camera.lockForConfiguration()
            
            // Enable continuous autofocus
            if camera.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus) {
                camera.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
            }
            
            // Enable auto focus range restriction if supported (for close-up focus)
            if #available(iOS 15.0, *) {
                if camera.isAutoFocusRangeRestrictionSupported {
                    camera.autoFocusRangeRestriction = AVCaptureDevice.AutoFocusRangeRestriction.near
                }
            }
            
            camera.unlockForConfiguration()
        } catch {
            // Error configuring camera
        }
        
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
    
    func toggleMacroMode() {
        guard isMacroAvailable else {
            return
        }
        
        isMacroEnabled.toggle()
        
        if isMacroEnabled {
            switchToMacroCamera()
        } else {
            // Switch back to normal camera
            switchToNormalCamera()
        }
    }
    
    private func switchToMacroCamera() {
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        // Get the ultra-wide camera for macro
        guard let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back),
              let newInput = try? AVCaptureDeviceInput(device: ultraWideCamera) else {
            return
        }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            currentCamera = ultraWideCamera
            
            // Configure for macro photography
            do {
                try ultraWideCamera.lockForConfiguration()
                
                // Set focus mode to continuous auto focus
                if ultraWideCamera.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus) {
                    ultraWideCamera.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                }
                
                // Set auto focus range restriction to near for macro
                if #available(iOS 15.0, *) {
                    if ultraWideCamera.isAutoFocusRangeRestrictionSupported {
                        ultraWideCamera.autoFocusRangeRestriction = AVCaptureDevice.AutoFocusRangeRestriction.near
                    }
                }
                
                // Lock the constituent device switching behavior if available (prevents automatic switching)
                if #available(iOS 16.0, *) {
                    if ultraWideCamera.isVirtualDevice && ultraWideCamera.constituentDevices.count > 0 {
                        ultraWideCamera.setPrimaryConstituentDeviceSwitchingBehavior(.locked, restrictedSwitchingBehaviorConditions: [])
                    }
                }
                
                ultraWideCamera.unlockForConfiguration()
            } catch {
                // Error configuring ultra wide camera
            }
        } else {
            // If we can't add the ultra wide camera input, add back the original one
            session.addInput(currentInput)
        }
        
        session.commitConfiguration()
    }
    
    private func switchToNormalCamera() {
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        // Get the wide angle camera (standard)
        guard let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let newInput = try? AVCaptureDeviceInput(device: wideCamera) else {
            return
        }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            currentCamera = wideCamera
            
            // Configure for normal photography
            do {
                try wideCamera.lockForConfiguration()
                
                // Set focus mode to continuous auto focus
                if wideCamera.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus) {
                    wideCamera.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                }
                
                // Reset auto focus range restriction
                if #available(iOS 15.0, *) {
                    if wideCamera.isAutoFocusRangeRestrictionSupported {
                        wideCamera.autoFocusRangeRestriction = AVCaptureDevice.AutoFocusRangeRestriction.none
                    }
                }
                
                wideCamera.unlockForConfiguration()
            } catch {
                // Error configuring wide camera
            }
        } else {
            // If we can't add the wide camera input, add back the original one
            session.addInput(currentInput)
        }
        
        session.commitConfiguration()
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
        
        // Configure focus settings for the new camera
        do {
            try newCamera.lockForConfiguration()
            
            // Enable continuous autofocus
            if newCamera.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus) {
                newCamera.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
            }
            
            // Enable auto focus range restriction if supported (for close-up focus)
            if #available(iOS 15.0, *) {
                if newCamera.isAutoFocusRangeRestrictionSupported {
                    newCamera.autoFocusRangeRestriction = AVCaptureDevice.AutoFocusRangeRestriction.near
                }
            }
            
            newCamera.unlockForConfiguration()
        } catch {
            // Error configuring camera
        }
        
        session.addInput(newInput)
        session.commitConfiguration()
        
        // Reset macro mode when flipping to front camera
        if newPosition == .front {
            isMacroEnabled = false
        }
    }
    
    // Add a method to focus on a specific point
    func focusOnPoint(_ point: CGPoint, in view: UIView) {
        guard let device = currentCamera else { return }
        
        // Convert the touch point to the coordinate system used by the camera
        let videoPreviewLayer = view.layer as? AVCaptureVideoPreviewLayer
        guard let captureDevicePoint = videoPreviewLayer?.captureDevicePointConverted(fromLayerPoint: point) else { return }
        
        do {
            try device.lockForConfiguration()
            
            // Check if the device supports focus at the specified point
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
                device.focusPointOfInterest = captureDevicePoint
                device.focusMode = AVCaptureDevice.FocusMode.autoFocus
            }
            
            // Also set exposure point if supported
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose) {
                device.exposurePointOfInterest = captureDevicePoint
                device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
            }
            
            device.unlockForConfiguration()
        } catch {
            // Error focusing camera
        }
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