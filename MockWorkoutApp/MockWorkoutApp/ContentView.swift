import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    enum MenuItem: String, CaseIterable, Identifiable {
        case workoutDashboard = "Workout with apple watch"
        case sleep = "Sleep"
        case heart = "Heart Detail"
        case running = "Running"
        case login = "Login"
        case strength = "Strength Training"
        case event = "Events"
        case opt = "Opt"

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
        case .strength:
            StrengthTrainingView()
        case .event:
            CalendarEventsView()
        case .opt:
            OTPCountdownView()
        }
    }
}

struct ContentSheet: View {
    @State private var showPicker = false
    @State private var weight = 70
    @State private var unit: WeightUnit = .kg

    var body: some View {
        VStack(spacing: 20) {
            Text("Weight: \(weight) \(unit.rawValue)")
                .font(.title2)
                .foregroundStyle(.white)

            Button("Select Weight") {
                showPicker = true
            }
        }
        .background(Color.black)

        .sheet(isPresented: $showPicker) {
            WeightPickerSheet(weight: $weight, unit: $unit)
        }
    }
}

enum WeightUnit: String, CaseIterable, Identifiable {
    case kg = "kg"
    case lbs = "lbs"

    var id: String { rawValue }
}


struct WeightPickerSheet: View {
    @Binding var weight: Int
    @Binding var unit: WeightUnit
    @Environment(\.dismiss) var dismiss

    let weights = Array(20...300)

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Weight")
                .font(.headline)

            HStack(spacing: 20) {
                // Weight Picker
                Picker("Weight", selection: $weight) {
                    ForEach(weights, id: \.self) { w in
                        Text("\(w)")
                            .tag(w)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                // Unit Picker (kg / lbs)
                Picker("Unit", selection: $unit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.rawValue)
                            .tag(unit)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 200)

            Button("Done") {
                dismiss()
            }
            .font(.headline)
            .padding(.top, 10)
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}


