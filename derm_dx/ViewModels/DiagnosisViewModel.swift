import Foundation
import UIKit
import SwiftUI

class DiagnosisViewModel: ObservableObject {
    private let diagnosisService = DiagnosisService()
    
    @Published var capturedImage: UIImage?
    @Published var diagnosisResult: DiagnosisResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func processDiagnosis(image: UIImage) {
        self.capturedImage = image
        self.isLoading = true
        self.diagnosisResult = nil
        self.errorMessage = nil
        
        diagnosisService.getDiagnosis(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.diagnosisResult = response
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func reset() {
        capturedImage = nil
        diagnosisResult = nil
        errorMessage = nil
    }
} 