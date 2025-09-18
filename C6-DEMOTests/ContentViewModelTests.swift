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
        viewModel = ContentViewModel(pitchService: mockPitchService)
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
        
        viewModel.$resultText
            .dropFirst()
            .sink {
                newText in
                XCTAssertEqual(newText, expectedText)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockPitchService.mockPitchSubject.send((testPitch, testAmplitude))
        
        wait(for: [expectation], timeout: 1.0)
    }
}
