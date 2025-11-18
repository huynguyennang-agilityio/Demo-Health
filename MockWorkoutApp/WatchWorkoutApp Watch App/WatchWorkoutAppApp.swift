import SwiftUI

@main
struct WatchWorkoutAppApp: App {
    @StateObject private var connectivity = WatchConnectivityServiceWatch.shared

    var body: some Scene {
        WindowGroup {
            WatchWorkoutView()
        }
    }

}
