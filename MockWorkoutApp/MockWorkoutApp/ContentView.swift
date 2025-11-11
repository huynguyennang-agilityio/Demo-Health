import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some View {
        // Check connect apple wacth
        WorkoutDashboardView()
        
        /// Sleep view
//        SleepView()
        
        /// Heart view
//        HeartDetailView()
    }
}
