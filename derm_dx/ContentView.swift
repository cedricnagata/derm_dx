//
//  ContentView.swift
//  derm_dx
//
//  Created by Cedric Nagata on 5/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DiagnosisViewModel()
    @State private var isShowingCamera = false
    @State private var isCropping = false
    @State private var cropOffset = CGSize.zero
    @State private var cropScale: CGFloat = 1.0
    @State private var lastOffset = CGSize.zero
    @State private var lastScale: CGFloat = 1.0
    @State private var initialImageSize: CGSize = .zero
    @State private var minScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    loadingView
                } else if let diagnosis = viewModel.diagnosisResult, let image = viewModel.capturedImage {
                    ResultsView(image: image, diagnosis: diagnosis, viewModel: viewModel)
                } else if let image = viewModel.capturedImage {
                    capturedImageView(image)
                        .onAppear {
                            // Calculate initial scale on image appear
                            calculateInitialScale(for: image)
                        }
                } else {
                    welcomeView
                }
            }
            .padding()
            .navigationTitle("DermDx")
            .sheet(isPresented: $isShowingCamera) {
                CustomCameraView(image: $viewModel.capturedImage)
                    .edgesIgnoringSafeArea(.all)
            }
            .alert(isPresented: .init(get: {
                viewModel.errorMessage != nil
            }, set: { _ in
                viewModel.errorMessage = nil
            })) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func calculateInitialScale(for image: UIImage) {
        // Calculate aspect ratio
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let imageAspect = imageWidth / imageHeight
        
        // Store image size for future reference
        initialImageSize = CGSize(width: imageWidth, height: imageHeight)
        
        // Reset crop parameters
        resetCropState()
        
        // Set initial scale based on aspect ratio to ensure the crop square is filled
        if imageAspect < 1 {
            // Portrait: ensure width fills the crop square
            minScale = 1.0
        } else {
            // Landscape: ensure height fills the crop square
            minScale = 1.0 / imageAspect
        }
        
        // Set initial scale to the minimum required scale
        cropScale = minScale
        lastScale = cropScale
    }
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Skin Lesion Analysis")
                .font(.title)
                .bold()
            
            Text("Take a photo of a skin lesion to receive an instant preliminary analysis.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                viewModel.capturedImage = nil
                isShowingCamera = true
            }) {
                HStack {
                    Image(systemName: "camera")
                    Text("Take Photo")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Text("DISCLAIMER: This app provides a preliminary assessment only and is not a substitute for professional medical advice. Always consult a healthcare provider for diagnosis and treatment.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    
    private func capturedImageView(_ image: UIImage) -> some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Text("Review & Crop Your Photo")
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                // Container for the image and crop square
                ZStack {
                    // Determine the crop square size
                    let cropSize = min(geometry.size.width, geometry.size.height) * 0.7
                    
                    // Container for the image with a clip mask of the crop square
                    ZStack {
                        // Background to make edges visible
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: cropSize, height: cropSize)
                        
                        // Display the image
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill() // Change to scaledToFill to ensure it fills the square
                            .scaleEffect(cropScale)
                            .offset(cropOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        cropOffset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = cropOffset
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let newScale = lastScale * value
                                        // Allow zooming out but not below the minimum scale that fills the square
                                        cropScale = max(minScale, newScale)
                                    }
                                    .onEnded { _ in
                                        lastScale = cropScale
                                    }
                            )
                    }
                    .frame(width: cropSize, height: cropSize)
                    .clipShape(Rectangle())
                    .overlay(
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                }
                .padding(.vertical)
                
                // Instructions
                Text("Drag to position • Pinch to zoom in/out")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Buttons
                HStack(spacing: 20) {
                    Button("Retake") {
                        viewModel.reset()
                        resetCropState()
                        isShowingCamera = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    
                    Button("Reset Crop") {
                        // Reset to the initial position that fills the square
                        calculateInitialScale(for: image)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    
                    Button("Analyze") {
                        // Create cropped image
                        let cropSize = min(geometry.size.width, geometry.size.height) * 0.7
                        if let croppedImage = createCroppedImage(
                            from: image,
                            with: cropOffset,
                            scale: cropScale,
                            cropSize: cropSize
                        ) {
                            viewModel.processDiagnosis(image: croppedImage)
                        } else {
                            viewModel.processDiagnosis(image: image)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func resetCropState() {
        cropOffset = .zero
        cropScale = 1.0
        lastOffset = .zero
        lastScale = 1.0
    }
    
    private func createCroppedImage(from image: UIImage, with offset: CGSize, scale: CGFloat, cropSize: CGFloat) -> UIImage? {
        // Create a renderer with the square crop size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: cropSize, height: cropSize))
        
        return renderer.image { context in
            // Fill with black background
            UIColor.black.setFill()
            context.fill(CGRect(x: 0, y: 0, width: cropSize, height: cropSize))
            
            // Get the image dimensions
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            let imageAspect = imageWidth / imageHeight
            
            // Calculate the size that will fill the crop square (not fit within it)
            var initialWidth: CGFloat
            var initialHeight: CGFloat
            
            if imageAspect < 1 {
                // Portrait - width equals crop size
                initialWidth = cropSize
                initialHeight = initialWidth / imageAspect
            } else {
                // Landscape - height equals crop size
                initialHeight = cropSize
                initialWidth = initialHeight * imageAspect
            }
            
            // Apply user scale
            let drawWidth = initialWidth * scale
            let drawHeight = initialHeight * scale
            
            // Calculate the center position with offset
            let centerX = cropSize / 2
            let centerY = cropSize / 2
            
            // Apply the offset to position the image
            let drawX = centerX - (drawWidth / 2) + offset.width
            let drawY = centerY - (drawHeight / 2) + offset.height
            
            // Draw the image with scale and offset
            image.draw(in: CGRect(x: drawX, y: drawY, width: drawWidth, height: drawHeight))
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(2)
            
            Text("Analyzing image...")
                .font(.title2)
                .padding(.top, 30)
            
            Text("This may take a few moments")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
