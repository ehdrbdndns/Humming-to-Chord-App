import Foundation

protocol KeyDetectionServiceProtocol {
    func pearsonCorrelation(vectorA: [Float], vectorB: [Float]) -> Float
    func calculatePCP(notes: [Note]) -> [Float]
    func findKey(for notes: [Note]) -> Key?
}
