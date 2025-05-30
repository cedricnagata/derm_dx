import Foundation
import UIKit

class DiagnosisService {
    // Replace with your actual API endpoint
    private let apiUrl = URL(string: "https://cedricnagata-skin-lesion-classifier--skin-lesion-cla-d628c3-dev.modal.run/predict")!
    
    func getDiagnosis(image: UIImage, completion: @escaping (Result<DiagnosisResponse, Error>) -> Void) {
        guard let imageData = prepareImageForAPI(image: image) else {
            completion(.failure(NSError(domain: "DiagnosisService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare image"])))
            return
        }
        
        // Create a request with multipart form data
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        
        // Create form data with the image
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the form data
        let formData = createFormData(with: imageData, boundary: boundary)
        
        print("Sending request to API with \(imageData.count) bytes of image data in form")
        
        // Use uploadTask to send the form data
        let task = URLSession.shared.uploadTask(with: request, from: formData) { data, response, error in
            if let error = error {
                print("API request error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Print response status code for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("API response status code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received from API")
                completion(.failure(NSError(domain: "DiagnosisService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("API response: \(responseString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(DiagnosisResponse.self, from: data)
                print("Successfully decoded response: \(response)")
                completion(.success(response))
            } catch {
                print("Failed to decode response: \(error)")
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
        return resizedImage.jpegData(compressionQuality: 0.95)
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
    
    private func createFormData(with imageData: Data, boundary: String) -> Data {
        var data = Data()
        
        // Add the image field
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n".data(using: .utf8)!)
        
        // Close the form
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data
    }
} 