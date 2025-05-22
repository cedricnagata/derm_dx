import Foundation
import UIKit

class DiagnosisService {
    // Replace with your actual API endpoint
    private let apiUrl = URL(string: "https://cedricnagata-skin-lesion-classifier--skin-lesion-classif-d628c3.modal.run/predict")!
    
    func getDiagnosis(image: UIImage, completion: @escaping (Result<DiagnosisResponse, Error>) -> Void) {
        guard let imageData = prepareImageForAPI(image: image) else {
            completion(.failure(NSError(domain: "DiagnosisService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare image"])))
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createMultipartFormData(boundary: boundary, imageData: imageData)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DiagnosisService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(DiagnosisResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func prepareImageForAPI(image: UIImage) -> Data? {
        // First, create a square version of the image
        let squareImage = cropToSquare(image: image)
        
        // Then resize to 384x384 for the API
        let targetSize = CGSize(width: 384, height: 384)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            squareImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        // Convert to JPEG data with high quality
        return resizedImage.jpegData(compressionQuality: 0.9)
    }
    
    private func cropToSquare(image: UIImage) -> UIImage {
        let size = min(image.size.width, image.size.height)
        let x = (image.size.width - size) / 2
        let y = (image.size.height - size) / 2
        let cropRect = CGRect(x: x, y: y, width: size, height: size)
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return image
    }
    
    private func createMultipartFormData(boundary: String, imageData: Data) -> Data {
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close the boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
} 