import XCTest
import Combine
import AudioKit

@testable import C6_DEMO

final class IntegrationTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        let splitter = AudioEngine().input!
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
    }
    
    func test_toggleRecording_updatesResultTextInViewModel() {
        let viewModel = ContentViewModel()
        let expectation = XCTestExpectation(description: "ViewModel의 resultText가 업데이트 되어야 합니다.")
        
        withObservationTracking {
            _ = viewModel.resultText
        } onChange: {
            expectation.fulfill()
        }
        
        viewModel.toggleRecording()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNotEqual(viewModel.resultText, "")
    }
}
