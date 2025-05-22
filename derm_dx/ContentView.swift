//
//  ContentView.swift
//  derm_dx
//
//  Created by Cedric Nagata on 5/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showWelcome = true
    
    var body: some View {
        ZStack {
            if showWelcome {
                welcomeView
            } else {
                CameraView()
            }
        }
    }
    
    private var welcomeView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "camera.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("DermDx")
                .font(.system(size: 40, weight: .bold))
            
            Text("Skin Lesion Analysis")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                welcomeFeatureRow(icon: "checkmark.circle.fill", text: "Take a photo of a skin lesion")
                welcomeFeatureRow(icon: "network", text: "Get instant analysis via cloud API")
                welcomeFeatureRow(icon: "cpu", text: "Offline analysis with local ML model")
                welcomeFeatureRow(icon: "exclamationmark.shield.fill", text: "Not a replacement for professional medical advice")
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    showWelcome = false
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
        .padding()
    }
    
    private func welcomeFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 22))
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    ContentView()
}
