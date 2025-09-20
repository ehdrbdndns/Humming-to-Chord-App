import Foundation
import Combine

typealias PitchData = (pitch: Double, amplitude: Double)

protocol PitchDetectionServiceProtocol {
    // 음의 높이(pitch)와 소리 크기(amplitude) 데이터를 방출(emit)하는 퍼블리셔입니다.
    var pitchPublisher: AnyPublisher<PitchData, Never> { get }
    
    func start() throws
    
    func stop()
}
