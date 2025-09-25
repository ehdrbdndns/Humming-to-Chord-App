import Foundation

final class NoteAggregatorService: NoteAggregatorServiceProtocol {
    private let TIME_INTERVAL = 0.1
    
    private var currentNote: Note?
    private var collectedNotes: [Note] = []
    
    private func finishCurrentNote() {
        if let note = currentNote {
            collectedNotes.append(note)
            currentNote = nil
        }
    }
    
    func add(pitch: Float, amplitude: Float) {
        
        // pitch filtering(20 ~ 4200)
        guard (20...4200).contains(pitch) else {
            finishCurrentNote()
            return;
        }
        
        
        // amplitude filtering
        guard amplitude > 0.01 else {
            finishCurrentNote()
            return
        }
        
        let midi = 12 * log2(pitch / 440) + 69
        guard let pitchClass = PitchClass(rawValue: Int(round(midi)) % 12) else {
            // TODO throw error message
            return
        }
        
        if currentNote == nil {
            currentNote = Note(pitchClass: pitchClass, duration: TIME_INTERVAL)
        } else if currentNote?.pitchClass == pitchClass {
            currentNote?.duration += TIME_INTERVAL
        } else {
            finishCurrentNote()
            currentNote = Note(pitchClass: pitchClass, duration: TIME_INTERVAL)
        }
    }
    
    func finalize() -> [Note] {
        finishCurrentNote()
        
        let finalNotes = collectedNotes
        
        currentNote = nil
        collectedNotes = []
        
        return finalNotes
    }
}
