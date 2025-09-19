import Foundation
import Combine

typealias PitchData = (pitch: Double, amplitude: Double)

protocol PitchDetectionServiceProtocol {
    // 음의 높이(pitch)와 소리 크기(amplitude) 데이터를 방출(emit)하는 퍼블리셔입니다.
    var pitchPublisher: AnyPublisher<PitchData, Never> { get }
    
    func start() throws
    
    func stop()
}

// ---

import AudioKit
import AVFoundation
import SoundpipeAudioKit

class PitchDetectionService: PitchDetectionServiceProtocol {
    var pitchPublisher: AnyPublisher<PitchData, Never> {
        pitchSubject.eraseToAnyPublisher()
    }
    
    private let engin = AudioEngine()
    private var mic: AudioEngine.InputNode?
    private var pitchTap: PitchTap?
    private let pitchSubject = PassthroughSubject<PitchData, Never>()
    
    func start() throws {
        // 오디오 권한 확인
        
        // 마이크 가져오기
        
        // PitchTap 생성 및 설치
        
        // PitchTap 핸들러 구현
        
        // 엔진 추력 설정 및 시작
    }
    
    func stop() {
        
    }
}
