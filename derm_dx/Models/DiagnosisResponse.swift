import Foundation

struct DiagnosisResponse: Codable {
    let prediction: Float
    let `class`: String
    let confidence: Float
} 