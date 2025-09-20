import AudioKit
import AVFoundation
import Foundation
import Combine
import OSLog

enum AudioEngineError: Error {
    case FailedToSetMicrophoneInput
    case FailedToSetPitchTap
}

let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "ContentViewModel"
)

@Observable
class ContentViewModel {
    private let engine: AudioEngine
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private(set) var resultText: String = ""
    private(set) var isRecording: Bool = false
    private(set) var errorText: String? = nil
    
    private let pitchService: PitchDetectionServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        do {
            try self.audioSession.setCategory(.playAndRecord, mode: .default)
            try self.audioSession.setActive(true)
        } catch {
            logger.error("Error setting up audio session: \(error.localizedDescription)")
            errorText = "잠시 후 다시 시도해 주세요."
        }
        
        self.engine = AudioEngine()
        self.pitchService = PitchDetectionService(engine: engine)
        
        engine.output = Mixer(self.engine.input!)
        
        setupSink()
    }
    
    // 테스트를 위한 생성자
    init(pitchService: PitchDetectionServiceProtocol) {
        self.engine = AudioEngine()
        self.pitchService = pitchService
        
        setupSink()
    }
    
    private func setupSink() {
        pitchService.pitchPublisher
            .sink { [weak self] (pitch, amplitude) in
                self?.resultText = "Pitch: \(pitch), Amp: \(amplitude)"
            }
            .store(in: &cancellables)
    }
    
    func toggleRecording() {
        if isRecording {
            pitchService.stop()
            engine.stop()
            isRecording = false
            return;
        }
        
        do {
            try pitchService.start()
            try engine.start()
            
            isRecording = true
        } catch {
            logger.error("Error starting pitch detection: \(error.localizedDescription)")
            errorText = "잠시 후 다시 시도해 주세요."
            isRecording = false
        }
    }
}
