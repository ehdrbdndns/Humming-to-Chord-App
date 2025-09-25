import Foundation

enum PitchClass: Int, CaseIterable {
    case C, CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B
}

struct Note: Equatable {
    let pitchClass: PitchClass
    var duration: TimeInterval // 음의 길이 (초)
}
