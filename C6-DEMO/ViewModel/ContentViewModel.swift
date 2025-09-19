import Foundation
import Combine
import OSLog

@Observable
class ContentViewModel {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "ContentViewModel"
    )
    
    private(set) var resultText: String = ""
    private(set) var isRecording: Bool = false
    private(set) var errorText: String? = nil
    
    private let pitchService: PitchDetectionServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(pitchService: PitchDetectionServiceProtocol) {
        self.pitchService = pitchService
        
        pitchService.pitchPublisher
            .sink { [weak self] (pitch, amplitude) in
                self?.resultText = "Pitch: \(pitch), Amp: \(amplitude)"
            }
            .store(in: &cancellables)
    }
    
    func toggleRecording() {
        do {
            if isRecording {
                pitchService.stop()
            } else {
                try pitchService.start()
            }
            
            isRecording.toggle()
        } catch {
            logger.error("Error starting pitch detection: \(error.localizedDescription)")
            errorText = "잠시 후 다시 시도해 주세요."
        }
    }
}
