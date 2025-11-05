import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()

    var body: some View {
        // Check connect apple wacth
//        VStack(spacing: 20) {
//            Text("📱 iOS App").font(.title)
//            Text("Heart Rate: \(viewModel.heartRate) bpm")
//            Text("Calories: \(viewModel.calories, specifier: "%.2f") kcal")
//            Text("Distance: \(viewModel.distance, specifier: "%.1f") m")
//
//            HStack {
//                Button("Start") {
//                    viewModel.start()
//                }
//                Button("Stop") {
//                    viewModel.stop()
//                }
//            }
//        }
//        .padding()
        
        /// Sleep view
        SleepView()
    }
}
