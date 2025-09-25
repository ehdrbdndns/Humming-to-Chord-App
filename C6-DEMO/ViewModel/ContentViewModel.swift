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
    private(set) var detectedKey: Key? = nil
    private(set) var waveformSamples: [Float] = []
    
    private(set) var errorText: String? = nil
    
    private let pitchService: PitchDetectionServiceProtocol
    private let noteAggregatorService: NoteAggregatorServiceProtocol
    private let keyDetectionService: KeyDetectionServiceProtocol
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
        guard let mic = self.engine.input else {
            fatalError("mic is nil")
        }
        let splitter = Mixer(mic)
        
        self.pitchService = PitchDetectionService(nodeToTap: splitter)
        self.noteAggregatorService = NoteAggregatorService()
        self.keyDetectionService = KeyDetectionService()
        
        engine.output = splitter
        
        setupSink()
    }
    
    // 테스트를 위한 생성자
    init(
        pitchService: PitchDetectionServiceProtocol,
        noteAggregatorService: NoteAggregatorServiceProtocol,
        keyDetectionService: KeyDetectionServiceProtocol
    ) {
        self.engine = AudioEngine()
        self.pitchService = pitchService
        self.noteAggregatorService = noteAggregatorService
        self.keyDetectionService = keyDetectionService
        
        setupSink()
    }
    
    private func setupSink() {
        pitchService.pitchPublisher
            .sink { [weak self] (pitch, amplitude) in
                guard let self = self else { return }
                
                self.noteAggregatorService.add(
                    pitch: Float(pitch),
                    amplitude: Float(amplitude)
                )
                
                DispatchQueue.main.async {
                    self.resultText = "Pitch: \(pitch), Amp: \(amplitude)"
                }
            }
            .store(in: &cancellables)
    }
    
    private func startRecording() throws {
        try pitchService.start()
        try engine.start()
        isRecording = true
        
        self.detectedKey = nil
    }
    
    private func stopRecording() {
        pitchService.stop()
        engine.stop()
        isRecording = false
        
        let notes = noteAggregatorService.finalize()
        self.detectedKey = keyDetectionService.findKey(for: notes)
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
            return;
        }
        
        do {
            try startRecording()
        } catch {
            logger.error("Error starting pitch detection: \(error.localizedDescription)")
            errorText = "잠시 후 다시 시도해 주세요."
            isRecording = false
        }
    }
    
    func clearError() {
        errorText = nil
    }
}

