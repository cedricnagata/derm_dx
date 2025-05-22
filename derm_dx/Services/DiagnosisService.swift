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
        // Resize to 384x384 and convert to JPG
        guard let resizedImage = image.resizedToSquare(size: 384) else { return nil }
        return resizedImage.jpegData(compressionQuality: 0.9)
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

// Extension to resize UIImage to square
extension UIImage {
    func resizedToSquare(size: CGFloat) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: format)
        return renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: size, height: size)
            // Fill with white background
            UIColor.white.setFill()
            context.fill(rect)
            
            // Center and scale the image while maintaining aspect ratio
            let drawRect: CGRect
            if self.size.width > self.size.height {
                let scaleFactor = size / self.size.height
                let scaledWidth = self.size.width * scaleFactor
                let xOffset = (scaledWidth - size) / 2
                drawRect = CGRect(x: -xOffset, y: 0, width: scaledWidth, height: size)
            } else {
                let scaleFactor = size / self.size.width
                let scaledHeight = self.size.height * scaleFactor
                let yOffset = (scaledHeight - size) / 2
                drawRect = CGRect(x: 0, y: -yOffset, width: size, height: scaledHeight)
            }
            
            self.draw(in: drawRect)
        }
    }
} 