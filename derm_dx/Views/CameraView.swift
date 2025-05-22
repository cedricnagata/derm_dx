import SwiftUI

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var showingResult = false
    @State private var predictionResult: PredictionResult?
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Camera preview
            if cameraManager.capturedImage == nil {
                CameraPreview(cameraManager: cameraManager)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            cameraManager.capturePhoto()
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 2)
                                        .frame(width: 60, height: 60)
                                )
                        }
                        .disabled(cameraManager.isCapturing || isAnalyzing)
                        
                        Spacer()
                    }
                    .padding(.bottom, 30)
                }
            } else if let image = cameraManager.capturedImage {
                // Image preview after capture
                if !showingResult {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            Spacer()
                            
                            HStack(spacing: 60) {
                                // Retake button
                                Button(action: {
                                    cameraManager.capturedImage = nil
                                    errorMessage = nil
                                }) {
                                    VStack {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 24))
                                        Text("Retake")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                }
                                
                                // Analyze button
                                Button(action: {
                                    analyzeImage(image)
                                }) {
                                    VStack {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 24))
                                        Text("Analyze")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                }
                                .disabled(isAnalyzing)
                            }
                            .padding(.bottom, 30)
                        }
                        
                        if isAnalyzing {
                            ZStack {
                                Color.black.opacity(0.7)
                                VStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(2)
                                    
                                    Text("Analyzing image...")
                                        .foregroundColor(.white)
                                        .padding(.top, 20)
                                        .font(.headline)
                                }
                            }
                        }
                        
                        if let error = errorMessage {
                            VStack {
                                Spacer()
                                
                                Text(error)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(10)
                                    .padding(.bottom, 100)
                            }
                        }
                    }
                }
            }
            
            // Results sheet
            if showingResult, let result = predictionResult, let image = cameraManager.capturedImage {
                ResultsView(image: image, result: result, isPresented: $showingResult)
            }
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
    
    private func analyzeImage(_ image: UIImage) {
        isAnalyzing = true
        errorMessage = nil
        
        PredictionService.shared.predictImage(image) { result in
            isAnalyzing = false
            
            DispatchQueue.main.async {
                switch result {
                case .success(let prediction):
                    self.predictionResult = prediction
                    self.showingResult = true
                    
                case .failure(let error):
                    self.errorMessage = "Analysis failed: \(error.localizedDescription)"
                    print("Prediction error: \(error)")
                }
            }
        }
    }
} 