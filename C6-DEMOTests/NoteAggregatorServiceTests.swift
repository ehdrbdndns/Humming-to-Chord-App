import XCTest
@testable import C6_DEMO

final class NoteAggregatorServiceTests: XCTestCase {
    override func setUp() {}
    
    override func tearDown() {}
    
    func test_aggregator_withStablePitch_createsOneNote() {
        let aggregatorSerivce = NoteAggregatorService()
        let expectedNote = Note(pitchClass: .A, duration: 0.5)
        
        aggregatorSerivce.add(pitch: 440.0, amplitude: 0.5)
        aggregatorSerivce.add(pitch: 440.0, amplitude: 0.5)
        aggregatorSerivce.add(pitch: 440.0, amplitude: 0.5)
        aggregatorSerivce.add(pitch: 440.0, amplitude: 0.5)
        aggregatorSerivce.add(pitch: 440.0, amplitude: 0.5)
        
        let notes = aggregatorSerivce.finalize()
        XCTAssertEqual(notes.count, 1, "음표는 하나만 생성되어야 합니다.")
        XCTAssertEqual(notes[0], expectedNote, "같은 주파수를 여러 번 들어주면, 하나의 음표만 생성되어야 합니다.")
    }
    
    func test_aggregator_withPitchChange_createsTwoNotes() {
        let aggregatorService = NoteAggregatorService()
        let expectedNotes = [
            Note(pitchClass: .A, duration: 0.2),
            Note(pitchClass: .G, duration: 0.3)
        ]
        
        aggregatorService.add(pitch: 440.0, amplitude: 0.5)
        aggregatorService.add(pitch: 440.0, amplitude: 0.5)
        aggregatorService.add(pitch: 392.0, amplitude: 0.5)
        aggregatorService.add(pitch: 392.0, amplitude: 0.5)
        aggregatorService.add(pitch: 392.0, amplitude: 0.5)
        
        let notes = aggregatorService.finalize()
        XCTAssertEqual(notes.count, 2, "음표는 두개 생성되어야 합니다.")
        XCTAssertEqual(notes[0].pitchClass, expectedNotes[0].pitchClass)
        XCTAssertEqual(notes[0].duration, expectedNotes[0].duration, accuracy: 0.0001)
        XCTAssertEqual(notes[1].pitchClass, expectedNotes[1].pitchClass)
        XCTAssertEqual(notes[1].duration, expectedNotes[1].duration, accuracy: 0.0001)
    }
    
    func test_aggregator_withSilenceInMiddle_createsTwoSeparateNotes() {
        let aggregatorService = NoteAggregatorService()
        let expectedNotes = [
            Note(pitchClass: .A, duration: 0.2),
            Note(pitchClass: .A, duration: 0.3)
        ]
        
        aggregatorService.add(pitch: 440.0, amplitude: 0.5)
        aggregatorService.add(pitch: 440.0, amplitude: 0.5)
        aggregatorService.add(pitch: 440.0, amplitude: 0.0001)
        aggregatorService.add(pitch: 440.0, amplitude: 0.5)
        aggregatorService.add(pitch: 440.0, amplitude: 0.5)
        aggregatorService.add(pitch: 440.0, amplitude: 0.5)
        
        let notes = aggregatorService.finalize()
        XCTAssertEqual(notes.count, 2, "음표는 두개 생성되어야 합니다.")
        XCTAssertEqual(notes[0].pitchClass, expectedNotes[0].pitchClass)
        XCTAssertEqual(notes[0].duration, expectedNotes[0].duration, accuracy: 0.0001)
        XCTAssertEqual(notes[1].pitchClass, expectedNotes[1].pitchClass)
        XCTAssertEqual(notes[1].duration, expectedNotes[1].duration, accuracy: 0.0001)
    }
    
    func test_aggregator_withVeryShortNote_ignoresNote() {
        let aggregatorService = NoteAggregatorService()
        
        aggregatorService.add(pitch: 440.0, amplitude: 0.5)
        
        let notes = aggregatorService.finalize()
        XCTAssertEqual(notes.count, 1, "음표는 하나여야 합니다.")
        XCTAssertEqual(notes[0], Note(pitchClass: .A, duration: 0.1))
    }
    
    func test_aggregator_withInvalidFrequencies_doesNotCreateNote() {
        let aggregatorService = NoteAggregatorService()
        
        aggregatorService.add(pitch: 10000.0, amplitude: 0.5)
        aggregatorService.add(pitch: -100, amplitude: 0.5)
        
        let notes = aggregatorService.finalize()
        XCTAssertTrue(notes.isEmpty, "음표가 생성되지 않아야 합니다.")
    }
}
