import Foundation

enum PitchClass: Int, CaseIterable {
    case C, CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B
}

struct Note {
    let pitchClass: PitchClass
    let duration: TimeInterval // 음의 길이 (초)
}
