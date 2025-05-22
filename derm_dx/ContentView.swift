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
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    loadingView
                } else if let diagnosis = viewModel.diagnosisResult, let image = viewModel.capturedImage {
                    ResultsView(image: image, diagnosis: diagnosis, viewModel: viewModel)
                } else if let image = viewModel.capturedImage {
                    capturedImageView(image)
                } else {
                    welcomeView
                }
            }
            .padding()
            .navigationTitle("DermDx")
            .sheet(isPresented: $isShowingCamera) {
                CameraView(image: $viewModel.capturedImage)
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
        VStack(spacing: 20) {
            Text("Review Your Photo")
                .font(.title)
                .bold()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            HStack(spacing: 20) {
                Button("Retake") {
                    viewModel.reset()
                    isShowingCamera = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(10)
                
                Button("Analyze") {
                    viewModel.processDiagnosis(image: image)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
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
