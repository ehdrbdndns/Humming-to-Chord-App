protocol ChordHarmonizationServiceProtocol {
    func getDiatonicChords(for: Key) -> [Chord]
    func getCandidateChords(for: Note, in: Key) -> [Chord]
}
