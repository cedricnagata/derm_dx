import SwiftUI

struct ResultsView: View {
    let image: UIImage
    let diagnosis: DiagnosisResponse
    @ObservedObject var viewModel: DiagnosisViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Diagnosis Results")
                .font(.title)
                .bold()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 10) {
                DiagnosisRow(title: "Diagnosis:", value: diagnosis.class.capitalized)
                DiagnosisRow(title: "Confidence:", value: String(format: "%.1f%%", diagnosis.confidence * 100))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(diagnosis.class == "benign" ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(diagnosis.class == "benign" ? Color.green : Color.red, lineWidth: 1)
            )
            
            Text(diagnosisMessage)
                .padding()
                .multilineTextAlignment(.center)
            
            Button("Take Another Photo") {
                viewModel.reset()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
    }
    
    var diagnosisMessage: String {
        if diagnosis.class == "benign" {
            return "The lesion appears to be benign. Continue to monitor for any changes and consult with a healthcare professional if you notice any changes."
        } else {
            return "The lesion has features that may be concerning. We recommend you consult with a healthcare professional for further evaluation as soon as possible."
        }
    }
}

struct DiagnosisRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(value)
        }
    }
} 