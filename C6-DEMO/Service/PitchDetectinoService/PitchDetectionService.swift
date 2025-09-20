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
    
    private let engine: AudioEngine
    private(set) var mic: AudioEngine.InputNode?
    private var pitchTap: PitchTap?
    private let pitchSubject = PassthroughSubject<PitchData, Never>()
    
    init(engine: AudioEngine) {
        self.engine = engine
    }
    
    func start() throws {
        guard let mic = engine.input else { throw PitchError.micNotFound }
        self.mic = mic
        
        pitchTap = PitchTap(mic) { [weak self] pitch, amp in
            DispatchQueue.main.async {
                guard let amplitude = amp.max(), !pitch.isEmpty else { return }
                let pitchValue = pitch.reduce(0, +) / Float(pitch.count)
                
                if amplitude > 0.01 {
                    self?.pitchSubject.send((pitch: Double(pitchValue), amplitude: Double(amplitude)))
                }
            }
        }
    
        pitchTap?.start()
    }
    
    func stop() {
        pitchTap?.stop()
    }
}
