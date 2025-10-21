import SwiftUI

@main
struct HelaApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        print("✅ HelaApp initialized")
        print("✅ PersistenceController loaded: \(persistenceController.container.name)")
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    print("✅ MainTabView appeared")
                }
        }
    }
}

