import SwiftUI

@main
struct ClearPhotosApp: App {
    @StateObject private var service = PhotoLibraryService()
    @StateObject private var store = ReviewStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(service)
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
