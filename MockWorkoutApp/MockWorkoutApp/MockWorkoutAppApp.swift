import SwiftUI

@main
struct MockWorkoutAppApp: App {
    // attach AppDelegate so service is created very early
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
