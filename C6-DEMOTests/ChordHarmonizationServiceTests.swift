import XCTest
import Combine
@testable import C6_DEMO

final class ChordHarmonizationServiceTests: XCTestCase {
    override func setUp() {}
    override func tearDown() {}
    
    func test_getDiatonicChords_forCMajor_returnsCorrectChords() {
        let service = ChordHarmonizationService()
        let cMajor = Key(root: .C, quality: .major)
        let expectedChords: [Chord] = [
            Chord(root: .C, quality: .major), Chord(root: .D, quality: .minor),
            Chord(root: .E, quality: .minor), Chord(root: .F, quality: .major),
            Chord(root: .G, quality: .major), Chord(root: .A, quality: .minor),
            Chord(root: .B, quality: .diminished)
        ]
        
        let chords = service.getDiatonicChords(for: cMajor)
        
        XCTAssertEqual(chords, expectedChords, "C Major 코드 배열이 반환되어야 합니다.")
    }
    
    func test_getDiatonicChords_forGMajor_returnsCorrectChords() {
        let service = ChordHarmonizationService()
        let gMajor = Key(root: .G, quality: .major)
        let expectedChords: [Chord] = [
            Chord(root: .G, quality: .major), Chord(root: .A, quality: .minor),
            Chord(root: .B, quality: .minor), Chord(root: .C, quality: .major),
            Chord(root: .D, quality: .major), Chord(root: .E, quality: .minor),
            Chord(root: .FSharp, quality: .diminished)
        ]
        
        let chords = service.getDiatonicChords(for: gMajor)
        
        XCTAssertEqual(chords, expectedChords, "G Major 코드 배열이 반환되어야 합니다.")
    }
    
    func test_getCandidateChords_forNoteE_inCMjorKey_returnsCorrectChords() {
        let service = ChordHarmonizationService()
        let cMajor = Key(root: .C, quality: .major)
        let noteE = Note(pitchClass: .E, duration: 1.0)
        let expectedChords: [Chord] = [
            Chord(root: .C, quality: .major), Chord(root: .E, quality: .minor), Chord(root: .A, quality: .minor)
        ]
        
        let chords = service.getCandidateChords(for: noteE, in: cMajor)
        
        XCTAssertEqual(chords, expectedChords, "후보 코드 배열이 반환되어야 합니다.")
    }
}
