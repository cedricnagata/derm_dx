import Foundation

struct DiagnosisResponse: Codable {
    let prediction: Float
    let `class`: String
    let confidence: Float
    
    // Add coding keys to handle possible variations in field names
    enum CodingKeys: String, CodingKey {
        case prediction
        case `class` = "class"
        case confidence
    }
    
    // Custom decoder to handle different response formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle prediction which might be a Float or String
        if let predictionValue = try? container.decode(Float.self, forKey: .prediction) {
            prediction = predictionValue
        } else if let predictionString = try? container.decode(String.self, forKey: .prediction),
                  let predictionValue = Float(predictionString) {
            prediction = predictionValue
        } else {
            prediction = 0.0
        }
        
        // Handle class
        `class` = try container.decode(String.self, forKey: .class)
        
        // Handle confidence which might be a Float or String
        if let confidenceValue = try? container.decode(Float.self, forKey: .confidence) {
            confidence = confidenceValue
        } else if let confidenceString = try? container.decode(String.self, forKey: .confidence),
                  let confidenceValue = Float(confidenceString) {
            confidence = confidenceValue
        } else {
            confidence = 0.0
        }
    }
} 