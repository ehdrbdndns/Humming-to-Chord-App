import SwiftUI
import AudioKit
import AVFoundation

// 이 테스트를 위한 간단한 오디오 관리 클래스
@Observable
class MinimalAudioTester {
    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    let splitter: Mixer
    var tap: RawDataTap?
    
    // 데이터 수신 성공 여부를 저장할 변수
    @MainActor var didGetData = false

    init() {
        // 우리가 논의한 '스플리터' 구조를 그대로 만듭니다.
        guard let mic = engine.input else { fatalError("Mic not found!") }
        self.mic = mic
        self.splitter = Mixer(mic)
        self.engine.output = self.splitter // 엔진 출력을 스플리터로 설정
        
        // 오디오 세션 설정
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Session setup error: \(error)")
        }
    }

    func start() {
        // 스플리터에 RawDataTap을 설치합니다.
        tap = RawDataTap(splitter) { buffer in
            // 데이터가 한 번이라도 들어오면, 성공으로 간주합니다.
            DispatchQueue.main.async {
                print(buffer)
                self.didGetData = true
            }
        }
        
        do {
            try engine.start()
            tap?.start()
        } catch {
            print("Engine start error: \(error)")
        }
    }
    
    func stop() {
        tap?.stop()
        engine.stop()
    }
}

// 위 Tester를 사용하는 간단한 UI
struct AudioSystemTestView: View {
    @State private var tester = MinimalAudioTester()

    var body: some View {
        VStack(spacing: 30) {
            Text(tester.didGetData ? "✅ SUCCESS: Received Audio Data!" : "⏳ WAITING FOR DATA...")
                .font(.largeTitle.bold())
                .foregroundColor(tester.didGetData ? .green : .red)
                .padding()
            
            Button("Start Test") {
                tester.start()
            }
            .font(.title)
            .buttonStyle(.borderedProminent)
        }
        .onDisappear {
            tester.stop()
        }
    }
}

#Preview {
    AudioSystemTestView()
}
