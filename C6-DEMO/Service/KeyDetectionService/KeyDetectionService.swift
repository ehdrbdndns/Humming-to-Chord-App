import Foundation
import Accelerate

class KeyDetectionService: KeyDetectionServiceProtocol {
    private let keyProfiles: [Key: [Float]] = [
        Key(root: .C, quality: .major): [6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88],
        Key(root: .CSharp, quality: .major): [2.88, 6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29],
        Key(root: .D, quality: .major): [2.29, 2.88, 6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66],
        Key(root: .DSharp, quality: .major): [3.66, 2.29, 2.88, 6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39],
        Key(root: .E, quality: .major): [2.39, 3.66, 2.29, 2.88, 6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19],
        Key(root: .F, quality: .major): [5.19, 2.39, 3.66, 2.29, 2.88, 6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52],
        Key(root: .FSharp, quality: .major): [2.52, 5.19, 2.39, 3.66, 2.29, 2.88, 6.35, 2.23, 3.48, 2.33, 4.38, 4.09],
        Key(root: .G, quality: .major): [4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88, 6.35, 2.23, 3.48, 2.33, 4.38],
        Key(root: .GSharp, quality: .major): [4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88, 6.35, 2.23, 3.48, 2.33],
        Key(root: .A, quality: .major): [2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88, 6.35, 2.23, 3.48],
        Key(root: .ASharp, quality: .major): [3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88, 6.35, 2.23],
        Key(root: .B, quality: .major): [2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88, 6.35],
        Key(root: .C, quality: .minor): [6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17],
        Key(root: .CSharp, quality: .minor): [3.17, 6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34],
        Key(root: .D, quality: .minor): [3.34, 3.17, 6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69],
        Key(root: .DSharp, quality: .minor): [2.69, 3.34, 3.17, 6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98],
        Key(root: .E, quality: .minor): [3.98, 2.69, 3.34, 3.17, 6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75],
        Key(root: .F, quality: .minor): [4.75, 3.98, 2.69, 3.34, 3.17, 6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54],
        Key(root: .FSharp, quality: .minor): [2.54, 4.75, 3.98, 2.69, 3.34, 3.17, 6.33, 2.68, 3.52, 5.38, 2.60, 3.53],
        Key(root: .G, quality: .minor): [3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17, 6.33, 2.68, 3.52, 5.38, 2.60],
        Key(root: .GSharp, quality: .minor): [2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17, 6.33, 2.68, 3.52, 5.38],
        Key(root: .A, quality: .minor): [5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17, 6.33, 2.68, 3.52],
        Key(root: .ASharp, quality: .minor): [3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17, 6.33, 2.68],
        Key(root: .B, quality: .minor): [2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17, 6.33]
    ]
    
    func pearsonCorrelation(vectorA: [Float], vectorB: [Float]) -> Float {
        guard !vectorA.isEmpty, vectorA.count == vectorB.count else { return 0 }
        
        let count = vDSP_Length(vectorA.count)
        
        // 각 벡터 평균
        var meanA: Float = 0.0
        var meanB: Float = 0.0
        vDSP_meanv(vectorA, 1, &meanA, count)
        vDSP_meanv(vectorB, 1, &meanB, count)
        
        var aMinusMean = [Float](repeating: 0, count: vectorA.count)
        var bMinusMean = [Float](repeating: 0, count: vectorB.count)
        vDSP_vsub(vectorA, 1, [meanA], 0, &aMinusMean, 1, count)
        vDSP_vsub(vectorB, 1, [meanB], 0, &bMinusMean, 1, count)
        
        var numerator: Float = 0
        vDSP_dotpr(aMinusMean, 1, bMinusMean, 1, &numerator, count)
        
        var aSqSum: Float = 0
        var bSqSum: Float = 0
        vDSP_dotpr(aMinusMean, 1, aMinusMean, 1, &aSqSum, count)
        vDSP_dotpr(bMinusMean, 1, bMinusMean, 1, &bSqSum, count)
        
        let denominator = sqrt(aSqSum * bSqSum)
        
        guard denominator != 0 else { return 0 }
        
        return numerator / denominator
    }
    
    func calculatePCP(notes: [Note]) -> [Float] {
        var pcp: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] // C, CSharp, D ...
        
        for note in notes {
            pcp[note.pitchClass.rawValue] += Float(note.duration)
        }
        
        return pcp
    }
    
    func findKey(for notes: [Note]) -> Key? {
        guard !notes.isEmpty else { return nil }
        
        let pcp = calculatePCP(notes: notes)
        
        var bestKey: Key? = nil
        var maxCorrelation: Float = -2.0
        
        for (key, profile) in keyProfiles {
            let correlation = pearsonCorrelation(vectorA: pcp, vectorB: profile)
        
            if correlation > maxCorrelation {
                maxCorrelation = correlation
                bestKey = key
            }
        }
        
        return bestKey
    }
    
}
