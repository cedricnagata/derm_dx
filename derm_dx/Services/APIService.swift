import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://cedricnagata--skin-lesion-classifier-flask-app.modal.run"
    
    private init() {}
    
    func predictImage(_ image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void) {
        guard let imageData = prepareImageData(image) else {
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        let url = URL(string: "\(baseURL)/predict")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = imageData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PredictionResult.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func prepareImageData(_ image: UIImage) -> Data? {
        // Resize to 384x384 as expected by the model
        guard let resizedImage = image.resize(to: CGSize(width: 384, height: 384)) else {
            return nil
        }
        
        // Convert to JPEG data
        return resizedImage.jpegData(compressionQuality: 0.9)
    }
    
    enum APIError: Error {
        case imageProcessingFailed
        case noData
    }
}

// UIImage extension for resizing
extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
} 