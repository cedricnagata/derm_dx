import SwiftUI

struct ResultsView: View {
    let image: UIImage
    let result: PredictionResult
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Skin Lesion Analysis")
                .font(.largeTitle)
                .bold()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .cornerRadius(12)
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Diagnosis")
                    .font(.headline)
                
                HStack {
                    Text(result.classification.capitalized)
                        .font(.title)
                        .foregroundColor(result.classification == "malignant" ? .red : .green)
                        .bold()
                    
                    Spacer()
                    
                    // Display confidence as percentage
                    Text("\(Int(result.confidence * 100))% confidence")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 5)
                )
                
                if result.classification == "malignant" {
                    Text("Warning: This is a preliminary result. Please consult a dermatologist for a professional diagnosis.")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                } else {
                    Text("Note: This is a preliminary result. Regular skin checks are still recommended.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
            }
            .padding()
            
            Button(action: {
                isPresented = false
            }) {
                Text("Take Another Photo")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
} 