import Foundation
import Combine

class ContentViewModel: ObservableObject {
    @Published var resultText: String = ""
    
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
}
