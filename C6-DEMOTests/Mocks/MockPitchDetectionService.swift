import Foundation
import Combine
@testable import C6_DEMO

enum TestError: Error {
    case intentionalError
}

class MockPitchDetectionService: PitchDetectionServiceProtocol {
    
    var pitchPublisher: AnyPublisher<PitchData, Never> {
        mockPitchSubject.eraseToAnyPublisher()
    }
    
    let mockPitchSubject = PassthroughSubject<PitchData, Never>()
    
    var startCalled = false
    var stopCalled = false
    
    var shouldThrowStartError = false
    
    func start() throws {
        if shouldThrowStartError {
            throw TestError.intentionalError
        }
        
        startCalled = true
    }
    
    func stop() {
        stopCalled = true
    }
}
