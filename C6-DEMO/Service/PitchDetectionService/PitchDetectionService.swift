import Combine
import AudioKit
import AVFoundation
import SoundpipeAudioKit

enum PitchError: Error {
    case micNotFound
    case setupFailed
}

class PitchDetectionService: PitchDetectionServiceProtocol {
    var pitchPublisher: AnyPublisher<PitchData, Never> {
        pitchSubject.eraseToAnyPublisher()
    }
    
    private let nodeToTap: Node
    private var pitchTap: PitchTap?
    private let pitchSubject = PassthroughSubject<PitchData, Never>()
    
    init(nodeToTap: Node) {
        self.nodeToTap = nodeToTap
    }
    
    func start() throws {
        pitchTap = PitchTap(nodeToTap) { [weak self] pitch, amp in
            DispatchQueue.main.async {
                guard let amplitude = amp.max(), !pitch.isEmpty else { return }
                let pitchValue = pitch.reduce(0, +) / Float(pitch.count)
                
                self?.pitchSubject.send((pitch: Double(pitchValue), amplitude: Double(amplitude)))
            }
        }
    
        pitchTap?.start()
    }
    
    func stop() {
        pitchTap?.stop()
    }
}
