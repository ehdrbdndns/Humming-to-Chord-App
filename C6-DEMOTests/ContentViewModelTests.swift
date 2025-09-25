import XCTest
import Combine
@testable import C6_DEMO

final class ContentViewModelTests: XCTestCase {
    var viewModel: ContentViewModel!
    var mockPitchService: MockPitchDetectionService!
    private var cancellables: Set<AnyCancellable>!
    
    // 각 테스트 케이스가 실행되기 전에 호출
    override func setUp() {
        super.setUp()
        mockPitchService = .init()
        viewModel = ContentViewModel(
            pitchService: mockPitchService,
            noteAggregatorService: NoteAggregatorService(),
            keyDetectionService: KeyDetectionService()
        )
        cancellables = []
    }
    
    // 각 테스트 케이스가 끝난 후에 호출
    override func tearDown() {
        viewModel = nil
        mockPitchService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func test_pitchPublisher_shouldUpdateResultText() {
        let testPitch: Double = 440.0 // 라 (A4) 음
        let testAmplitude: Double = 0.5
        let expectedText = "Pitch: 440.0, Amp: 0.5"
        
        let expectation = XCTestExpectation(description: "resultText가 예상대로 업데이트되어야 합니다.")
        
        withObservationTracking {
            _ = viewModel.resultText
        } onChange: {
            expectation.fulfill()
        }
        
        mockPitchService.mockPitchSubject.send((testPitch, testAmplitude))
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(self.viewModel.resultText, expectedText)
    }
    
    func test_toggleRecording_shouldCallStartOnService() {
        viewModel.toggleRecording()
        
        XCTAssertTrue(mockPitchService.startCalled, "toggleRecording()을 호출하면 pitchService.start()가 호출되어야 합니다.")
    }
    
    func test_toggleRecording_whenNotRecording_shoudSetIsRecordingToTrue() {
        let expectation = XCTestExpectation(description: "isRecording 상태가 true여야 합니다.")
        
        withObservationTracking {
            _ = viewModel.isRecording
        } onChange: {
            expectation.fulfill()
        }
    
        viewModel.toggleRecording()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(viewModel.isRecording, "녹음이 시작되면 isRecording 상태가 true여야 합니다.")
    }
    
    func test_toggleRecording_whenRecording_shouldCallStopOnService() {
        viewModel.toggleRecording()
        
        viewModel.toggleRecording()
        
        XCTAssertTrue(mockPitchService.stopCalled, "녹음 중일 때 toggleRecording()을 호출하면 pitchService.stop()이 호출되어야 합니다.")
    }
    
    func test_toggleRecording_whenRecording_shouldSetIsRecordingToFalse() {
        let expectation = XCTestExpectation(description: "isRecording 상태가 false여야 합니다.")
        
        viewModel.toggleRecording()
        
        withObservationTracking {
            _ = viewModel.isRecording
        } onChange: {
            expectation.fulfill()
        }
        
        viewModel.toggleRecording()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isRecording, "녹음이 중지되면 isRecording 상태가 false여야 합니다.")
    }
    
    func test_toggleRecording_whenErrorOccurred_shouldShowErrorMessage() {
        mockPitchService.shouldThrowStartError = true
        
        let expectation = XCTestExpectation(description: "에러 메시지가 표시되어야 합니다.")
        
        withObservationTracking {
            _ = viewModel.errorText
        } onChange: {
            expectation.fulfill()
        }
        
        viewModel.toggleRecording()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.errorText, "잠시 후 다시 시도해 주세요.")
    }
    
    func test_clearError_shouldSetErrorMessageToNil() {
        let expectation = XCTestExpectation(description: "에러 메시지가 nil 값이어야 합니다.")
        
        mockPitchService.shouldThrowStartError = true
        viewModel.toggleRecording()
        
        withObservationTracking {
            _ = viewModel.errorText
        } onChange: {
            expectation.fulfill()
        }

        viewModel.clearError()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNil(viewModel.errorText)
    }
}
