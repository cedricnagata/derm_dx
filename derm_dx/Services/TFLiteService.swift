import Foundation
import UIKit
import CoreML
import TensorFlowLiteSwift

class TFLiteService {
    static let shared = TFLiteService()
    
    private var interpreter: Interpreter?
    private let modelName = "slc_85"
    
    private init() {
        setupInterpreter()
    }
    
    private func setupInterpreter() {
        guard let modelPath = Bundle.main.path(forResource: modelName, ofType: "tflite") else {
            print("Failed to find model file: \(modelName).tflite")
            return
        }
        
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter?.allocateTensors()
        } catch {
            print("Failed to create interpreter: \(error.localizedDescription)")
        }
    }
    
    func predictImage(_ image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void) {
        guard let interpreter = interpreter else {
            completion(.failure(TFLiteError.interpreterNotInitialized))
            return
        }
        
        guard let inputData = prepareInputData(from: image) else {
            completion(.failure(TFLiteError.imageProcessingFailed))
            return
        }
        
        do {
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()
            
            guard let outputTensor = try? interpreter.output(at: 0) else {
                completion(.failure(TFLiteError.outputProcessingFailed))
                return
            }
            
            let prediction = outputTensor.data.withUnsafeBytes { pointer in
                pointer.load(as: Float.self)
            }
            
            let isNormalizedValue = prediction >= 0 && prediction <= 1.0
            let finalPrediction = isNormalizedValue ? prediction : (prediction > 0 ? 1.0 : 0.0)
            
            let result = PredictionResult(
                prediction: finalPrediction,
                classification: finalPrediction > 0.5 ? "malignant" : "benign",
                confidence: finalPrediction > 0.5 ? finalPrediction : 1.0 - finalPrediction
            )
            
            completion(.success(result))
            
        } catch {
            completion(.failure(error))
        }
    }
    
    private func prepareInputData(from image: UIImage) -> Data? {
        guard let resizedImage = image.resize(to: CGSize(width: 384, height: 384)),
              let cgImage = resizedImage.cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 3
        var pixelData = [UInt8](repeating: 0, count: width * height * 3)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Convert to float32 and normalize to [0,1]
        var normalizedBuffer = Data(count: width * height * 3 * 4) // 4 bytes per float32
        
        for i in 0..<pixelData.count {
            let normalizedValue = Float(pixelData[i]) / 255.0
            let bytes = withUnsafeBytes(of: normalizedValue) { Array($0) }
            normalizedBuffer.replaceSubrange(i*4..<i*4+4, with: bytes)
        }
        
        return normalizedBuffer
    }
    
    enum TFLiteError: Error {
        case interpreterNotInitialized
        case imageProcessingFailed
        case outputProcessingFailed
    }
} 