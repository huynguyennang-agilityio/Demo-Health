import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    enum MenuItem: String, CaseIterable, Identifiable {
        case workoutDashboard = "Workout with apple watch"
        case sleep = "Sleep"
        case heart = "Heart Detail"
        case running = "Running"
        case login = "Login"

        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            List(MenuItem.allCases) { item in
                NavigationLink(item.rawValue, destination: destinationView(for: item))
            }
            .navigationTitle("Dashboard")
        }
    }
    
    @ViewBuilder
    func destinationView(for item: MenuItem) -> some View {
        switch item {
        case .workoutDashboard:
            WorkoutDashboardView()
        case .sleep:
            SleepView()
        case .heart:
            HeartDetailView()
        case .running:
            RunningView()
        case .login:
            LoginForm()
        }
    }
}
