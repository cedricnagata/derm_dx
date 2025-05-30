import SwiftUI
import UIKit

struct ImageCropView: View {
    let originalImage: UIImage
    @Binding var croppedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Text("Position the lesion in the square")
                    .font(.headline)
                    .padding(.top)
                    .foregroundColor(.white)
                
                ZStack {
                    // Square crop area
                    let cropSize = min(geometry.size.width, geometry.size.height) * 0.8
                    
                    // Fixed size container for the image
                    ZStack {
                        // Background to show clipping area
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: cropSize, height: cropSize)
                        
                        // Image to crop
                        Image(uiImage: originalImage)
                            .resizable()
                            .scaledToFit() // Changed to fit to ensure image is fully visible initially
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = max(1.0, lastScale * value)
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                    }
                            )
                    }
                    .frame(width: cropSize, height: cropSize)
                    .clipShape(Rectangle())
                    .overlay(
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    
                    // Instructions text
                    VStack {
                        Spacer()
                        Text("Drag to position • Pinch to zoom")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                            .padding(.bottom, 10)
                    }
                    .frame(width: cropSize)
                }
                
                HStack(spacing: 40) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    Button("Reset") {
                        offset = .zero
                        scale = 1.0
                        lastOffset = .zero
                        lastScale = 1.0
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    Button("Crop") {
                        // Create the cropped image using a simpler approach
                        if let croppedImg = createCroppedImage(from: originalImage, with: offset, scale: scale, cropSize: min(geometry.size.width, geometry.size.height) * 0.8) {
                            croppedImage = croppedImg
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                setupInitialScale()
            }
        }
    }
    
    // Set up initial scale to fit the image properly
    private func setupInitialScale() {
        // Calculate aspect ratio to fit image initially
        let imageAspect = originalImage.size.width / originalImage.size.height
        if imageAspect > 1 {
            // Landscape image
            scale = 1.0 / imageAspect
            lastScale = scale
        }
    }
    
    // Simpler approach to crop the image
    private func createCroppedImage(from image: UIImage, with offset: CGSize, scale: CGFloat, cropSize: CGFloat) -> UIImage? {
        // Create a renderer with the target size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: cropSize, height: cropSize))
        
        return renderer.image { context in
            // Fill with black background
            UIColor.black.setFill()
            context.fill(CGRect(x: 0, y: 0, width: cropSize, height: cropSize))
            
            // Calculate the centered rect for the image
            let imageSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            
            let x = (cropSize - imageSize.width) / 2 + offset.width
            let y = (cropSize - imageSize.height) / 2 + offset.height
            
            // Draw the image with the current position and scale
            image.draw(in: CGRect(x: x, y: y, width: imageSize.width, height: imageSize.height))
        }
    }
} 