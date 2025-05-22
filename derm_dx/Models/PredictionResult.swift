import Foundation

struct PredictionResult: Codable {
    let prediction: Float
    let classification: String
    let confidence: Float
    
    enum CodingKeys: String, CodingKey {
        case prediction
        case classification = "class"
        case confidence
    }
} 