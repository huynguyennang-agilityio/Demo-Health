import SwiftUI

struct WatchContentView: View {
    @StateObject private var viewModel = WorkoutViewModelWatch()

    var body: some View {
        VStack(spacing: 10) {
            Text("⌚️ Watch App test").font(.title3)
            Text("Heart Rate: \(viewModel.heartRate) bpm")

            HStack {
                Button("Start") {
                    viewModel.start()
                }
                Button("Stop") {
                    viewModel.stop()
                }
            }
        }
        .padding()
    }
}
