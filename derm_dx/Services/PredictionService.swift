import Foundation
import UIKit

class PredictionService {
    static let shared = PredictionService()
    
    private init() {}
    
    func predictImage(_ image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void) {
        // First try the API
        APIService.shared.predictImage(image) { result in
            switch result {
            case .success(let predictionResult):
                // API call was successful
                completion(.success(predictionResult))
                
            case .failure(let error):
                print("API prediction failed, falling back to local model: \(error.localizedDescription)")
                
                // Fallback to local TFLite model
                TFLiteService.shared.predictImage(image) { localResult in
                    switch localResult {
                    case .success(let predictionResult):
                        completion(.success(predictionResult))
                        
                    case .failure(let localError):
                        completion(.failure(PredictionError.bothMethodsFailed(apiError: error, localError: localError)))
                    }
                }
            }
        }
    }
    
    enum PredictionError: Error, LocalizedError {
        case bothMethodsFailed(apiError: Error, localError: Error)
        
        var errorDescription: String? {
            switch self {
            case .bothMethodsFailed(let apiError, let localError):
                return "Both prediction methods failed. API error: \(apiError.localizedDescription), Local error: \(localError.localizedDescription)"
            }
        }
    }
} 