import Foundation
import Combine
@testable import C6_DEMO

class MockPitchDetectionService: PitchDetectionServiceProtocol {
    
    var pitchPublisher: AnyPublisher<PitchData, Never> {
        mockPitchSubject.eraseToAnyPublisher()
    }
    
    let mockPitchSubject = PassthroughSubject<PitchData, Never>()
    
    var startCalled = false
    var stopCalled = false
    
    func start() {
        startCalled = true
    }
    
    func stop() {
        stopCalled = true
    }
}
