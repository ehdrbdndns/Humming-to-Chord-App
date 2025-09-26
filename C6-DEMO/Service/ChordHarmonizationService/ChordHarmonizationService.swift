final class ChordHarmonizationService: ChordHarmonizationServiceProtocol {
    private let scalePatterns: [KeyQuality: [ChordQuality]] = [
        .major: [.major, .minor, .minor, .major, .major, .minor, .diminished],
        .minor: [.minor, .diminished, .major, .minor, .minor, .major, .major]
    ]
    
    private let scaleIntervals: [KeyQuality: [Int]] = [
        .major: [0, 2, 4, 5, 7, 9, 11],
        .minor: [0, 2, 3, 5, 7, 8, 10]
    ]
    
    func getDiatonicChords(for key: Key) -> [Chord] {
        var chords: [Chord] = []
        
        guard let scalePattern = self.scalePatterns[key.quality]
            , let scaleIntervals = self.scaleIntervals[key.quality]
        else {
            return []
        }
        
        
        for i in 0..<7 {
            let rootRawValue = (key.root.rawValue + scaleIntervals[i]) % 12
            guard let root = PitchClass(rawValue: rootRawValue) else { continue }
            chords.append(Chord(root: root, quality: scalePattern[i]))
        }
        
        return chords
    }
    
    func getCandidateChords(for note: Note, in key: Key) -> [Chord] {
        var diatonicChords: [Chord] = self.getDiatonicChords(for: key)
        
        let candidateChords: [Chord] = diatonicChords.filter { chord in
            return chord.constituentNotes.contains(note.pitchClass)
        }

        return candidateChords
    }
}
