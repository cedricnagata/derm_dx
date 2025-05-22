import Foundation
import AVFoundation
import UIKit

class CameraManager: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isCapturing = false
    @Published var error: Error?
    
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        session.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            error = CameraError.unableToSetupCamera
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            error = CameraError.unableToSetupCamera
            session.commitConfiguration()
            return
        }
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            error = CameraError.unableToSetupCamera
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func capturePhoto() {
        isCapturing = true
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        if let existingLayer = videoPreviewLayer {
            return existingLayer
        }
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        videoPreviewLayer = layer
        
        return layer
    }
    
    enum CameraError: Error, LocalizedError {
        case unableToSetupCamera
        case captureError
        
        var errorDescription: String? {
            switch self {
            case .unableToSetupCamera:
                return "Unable to setup camera"
            case .captureError:
                return "Failed to capture photo"
            }
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        isCapturing = false
        
        if let error = error {
            self.error = error
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            self.error = CameraError.captureError
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = image
        }
    }
} 