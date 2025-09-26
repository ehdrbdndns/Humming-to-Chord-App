import XCTest
@testable import C6_DEMO

final class ChordHarmonizationServiceTests: XCTestCase {

    var service: ChordHarmonizationService!

    override func setUp() {
        super.setUp()
        service = ChordHarmonizationService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Test Cases

    func test_getDiatonicChords_forCMajor_returnsCorrectChords() {
        let key = Key(root: .C, quality: .major)
        let expectedChords: [Chord] = [
            Chord(root: .C, quality: .major), Chord(root: .D, quality: .minor),
            Chord(root: .E, quality: .minor), Chord(root: .F, quality: .major),
            Chord(root: .G, quality: .major), Chord(root: .A, quality: .minor),
            Chord(root: .B, quality: .diminished)
        ]
        
        let chords = service.getDiatonicChords(for: key)
        
        XCTAssertEqual(chords, expectedChords)
    }

    func test_getCandidateChords_forNoteE_inCMajorKey_returnsCorrectChords() {
        let key = Key(root: .C, quality: .major)
        let note = Note(pitchClass: .E, duration: 1.0)
        let expectedChords: [Chord] = [
            Chord(root: .C, quality: .major), 
            Chord(root: .E, quality: .minor), 
            Chord(root: .A, quality: .minor)
        ]
        
        let chords = service.getCandidateChords(for: note, in: key)
        
        XCTAssertEqual(Set(chords), Set(expectedChords))
    }

    // 👇 This test is currently failing because we are focusing on the test itself.
    func test_harmonize_withSimpleMelody_returnsPlausibleProgression() {
        // Given
        let key = Key(root: .C, quality: .major)
        // 4/4 time, at 120BPM, each 1-second note spans 2 beats.
        // Therefore [C, G] form one measure, and [A, F] form another measure.
        let melody: [Note] = [
            Note(pitchClass: .C, duration: 1.0),
            Note(pitchClass: .G, duration: 1.0),
            Note(pitchClass: .A, duration: 1.0),
            Note(pitchClass: .F, duration: 1.0)
        ]
        // Our goal is to infer the I-V-vi-IV progression.
        let expectedProgression: [Chord] = [
            Chord(root: .C, quality: .major),
            Chord(root: .F, quality: .major)
        ]
        
        let bpm: Double = 120
        let timeSignature = TimeSignature(beats: 4, noteValue: 4)

        // When
        let progression = service.harmonize(melody: melody, key: key, bpm: bpm, timeSignature: timeSignature)
        
        // Then
        XCTAssertEqual(progression, expectedProgression, "A simple I-V-vi-IV progression should be inferred for the simple melody.")
    }

    func test_segment_withSpanningNote_splitsNoteCorrectly() {
        // Given
        let measureDuration: TimeInterval = 2.0 // 한 마디는 2초라고 가정
        
        // 1.5초에 시작해서 1초 동안 지속되는 'C' 음표 (즉, 2.5초에 끝남)
        let melody: [Note] = [
            Note(pitchClass: .A, duration: 1.5),
            Note(pitchClass: .C, duration: 1.0) 
        ]
        
        // When
        // segment 메서드를 직접 호출하여 결과를 확인합니다.
        let measures = service.segment(notes: melody, intoMeasuresOf: measureDuration)
        
        // Then
        XCTAssertEqual(measures.count, 2, "멜로디는 두 마디로 나뉘어야 합니다.")
        
        // 첫 번째 마디 검증
        XCTAssertEqual(measures.first?.count, 2, "첫 번째 마디는 두 개의 음표를 가져야 합니다.")
        XCTAssertEqual(measures.first?.last?.pitchClass, .C)
        if let duration = measures.first?.last?.duration {
            XCTAssertEqual(duration, 0.5, accuracy: 0.001, "첫 마디의 두 번째 음표(C)는 0.5초 길이여야 합니다.")
        } else {
            XCTFail("첫 마디에 C 음표가 없습니다.")
        }
        
        // 두 번째 마디 검증
        XCTAssertEqual(measures.last?.count, 1, "두 번째 마디는 하나의 음표를 가져야 합니다.")
        XCTAssertEqual(measures.last?.first?.pitchClass, .C)
        if let duration = measures.last?.first?.duration {
            XCTAssertEqual(duration, 0.5, accuracy: 0.001, "두 번째 마디의 첫 음표(C)는 나머지 0.5초 길이여야 합니다.")
        } else {
            XCTFail("두 번째 마디에 C 음표가 없습니다.")
        }
    }
}
