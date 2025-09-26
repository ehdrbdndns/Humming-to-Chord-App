import Foundation

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
        let diatonicChords: [Chord] = self.getDiatonicChords(for: key)
        
        let candidateChords: [Chord] = diatonicChords.filter { chord in
            return chord.constituentNotes.contains(note.pitchClass)
        }

        return candidateChords
    }
    
    // MARK: - Main Harmonization Method
    func harmonize(melody: [Note], key: Key, bpm: Double, timeSignature: TimeSignature) -> [Chord] {
        guard bpm > 0, !melody.isEmpty else { return [] }

        let quarterNoteDuration = 60.0 / bpm
        let beatDuration = quarterNoteDuration * (4.0 / Double(timeSignature.noteValue))
        let measureDuration = beatDuration * Double(timeSignature.beats)
        
        // 멜로디에서 마디 분리
        let measures = segment(notes: melody, intoMeasuresOf: measureDuration)
        
        var progression: [Chord] = []
        var previousChord: Chord? = nil

        // 마디 별 코드 추천
        for notesInMeasure in measures {
            guard !notesInMeasure.isEmpty else { continue }
            
            let candidateChords = findCandidateChords(for: notesInMeasure, in: key)
            
            let bestChord = scoreAndSelectBestChord(
                candidates: candidateChords,
                notesInMeasure: notesInMeasure,
                previousChord: previousChord,
                key: key
            )
            
            if let bestChord = bestChord {
                progression.append(bestChord)
                previousChord = bestChord
            } else if let lastChord = progression.last {
                progression.append(lastChord)
            }
        }
        
        return progression
    }

    // MARK: - Private Helpers for Harmonization

    func segment(notes: [Note], intoMeasuresOf measureDuration: TimeInterval) -> [[Note]] {
        guard measureDuration > 0 else { return [notes] }

        var measures: [[Note]] = []
        var currentMeasure: [Note] = []
        var currentDuration: TimeInterval = 0

        for var note in notes {
            while currentDuration + note.duration > measureDuration {
                let remainingDurationInMeasure = measureDuration - currentDuration
                
                if remainingDurationInMeasure > 0 {
                    let firstPiece = Note(pitchClass: note.pitchClass, duration: remainingDurationInMeasure)
                    currentMeasure.append(firstPiece)
                }

                if !currentMeasure.isEmpty {
                    measures.append(currentMeasure)
                }
                
                currentMeasure = []
                currentDuration = 0
                
                note.duration -= remainingDurationInMeasure
            }
            
            // Add the note (or its remaining part) to the current measure
            currentMeasure.append(note)
            currentDuration += note.duration
        }

        // Add the very last measure if it has any notes
        if !currentMeasure.isEmpty {
            measures.append(currentMeasure)
        }
        
        return measures
    }
    
    private func findCandidateChords(for notes: [Note], in key: Key) -> [Chord] {
        let diatonicChords = getDiatonicChords(for: key)
        let uniquePitchClasses = Set(notes.map { $0.pitchClass })
        
        let candidates = diatonicChords.filter { chord in
            let chordNotes = Set(chord.constituentNotes)
            return !chordNotes.isDisjoint(with: uniquePitchClasses)
        }
        return candidates
    }
    
    private func scoreAndSelectBestChord(
        candidates: [Chord], notesInMeasure: [Note], previousChord: Chord?, key: Key
    ) -> Chord? {
        guard !candidates.isEmpty else { return nil }

        var scores: [Chord: Double] = [:]

        for candidate in candidates {
            var currentScore = 0.0
            currentScore += noteCoverageScore(for: candidate, in: notesInMeasure)
            currentScore += beatStrengthScore(for: candidate, in: notesInMeasure)
            currentScore += progressionScore(from: previousChord, to: candidate, in: key)
            currentScore += chordWeightScore(for: candidate, in: key)
            scores[candidate] = currentScore
        }

        return scores.max { $0.value < $1.value }?.key
    }
    
    // MARK: - Scoring Functions

    private func noteCoverageScore(for chord: Chord, in notes: [Note]) -> Double {
        let chordNotes = Set(chord.constituentNotes)
        let melodyNotes = Set(notes.map { $0.pitchClass })
        let intersection = chordNotes.intersection(melodyNotes)
        return Double(intersection.count)
    }

    private func beatStrengthScore(for chord: Chord, in notes: [Note]) -> Double {
        if let firstNote = notes.first, chord.constituentNotes.contains(firstNote.pitchClass) {
            return 1.5
        }
        return 0
    }

    private func progressionScore(from previous: Chord?, to current: Chord, in key: Key) -> Double {
        guard let previous = previous,
              let prevDegree = degree(for: previous, in: key),
              let currDegree = degree(for: current, in: key) else { return 0 }

        let progression = (prevDegree, currDegree)
        switch progression {
        case (5, 1): return 2.0 // V -> I
        case (4, 5), (2, 5): return 1.5 // IV -> V, ii -> V
        case (6, 2), (1, 4): return 1.0 // vi -> ii, I -> IV
        case (5, 4): return -1.0 // V -> IV
        default: return 0.5
        }
    }

    private func chordWeightScore(for chord: Chord, in key: Key) -> Double {
        guard let degree = degree(for: chord, in: key) else { return 0 }
        switch degree {
        case 1, 4, 5: return 0.5 // Tonic, Subdominant, Dominant
        case 2, 6: return 0.2 // Supertonic, Submediant
        default: return 0.1
        }
    }
    
    private func degree(for chord: Chord, in key: Key) -> Int? {
        let scaleIntervals = key.quality == .major ? [0, 2, 4, 5, 7, 9, 11] : [0, 2, 3, 5, 7, 8, 10]
        let rootDistance = (12 + chord.root.rawValue - key.root.rawValue) % 12
        if let index = scaleIntervals.firstIndex(of: rootDistance) {
            return index + 1 // 1-based degree (I, II, III...)
        }
        return nil
    }
}
