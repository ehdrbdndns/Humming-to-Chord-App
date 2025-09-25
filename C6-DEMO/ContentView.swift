import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Hum to Chords")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            // Waveform View Placeholder
            ZStack {
                Rectangle()
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(10)
                Text("Waveform will be here")
                    .foregroundStyle(.secondary)
            }
            .frame(height: 100)

            // Result Text View
            Text(viewModel.resultText.isEmpty ? "Press Record to start analyzing" : viewModel.resultText)
                .font(.headline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding()
                .frame(height: 50)
            
            Spacer()
            
            // Fixed: Avoid string interpolation with optional
            if let detectedKey = viewModel.detectedKey {
                Text(String(describing: detectedKey.root))
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding()
                    .frame(height: 50)
                Text(String(describing: detectedKey.quality))
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding()
                    .frame(height: 50)
            } else {
                Text("waiting...")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding()
                    .frame(height: 50)
            }
            
            Spacer()

            // Record/Stop Button
            Button {
                viewModel.toggleRecording()
            } label: {
                Text(viewModel.isRecording ? "Stop" : "Record")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .background(viewModel.isRecording ? Color.red : Color.blue)
                    .clipShape(Circle())
                    .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            
            Spacer()
        }
        .padding()
        .alert(
            "An Error Occurred",
            isPresented: Binding(
                get: { viewModel.errorText != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorText ?? "An unknown error occurred.")
        }
    }
}

#Preview {
    ContentView()
}
