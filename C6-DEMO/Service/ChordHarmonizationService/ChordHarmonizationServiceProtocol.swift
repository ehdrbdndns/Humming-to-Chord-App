import Foundation

protocol ChordHarmonizationServiceProtocol {
    func getDiatonicChords(for key: Key) -> [Chord]
    func getCandidateChords(for note: Note, in key: Key) -> [Chord]
    func harmonize(melody: [Note], key: Key, bpm: Double, timeSignature: TimeSignature) -> [Chord]
}