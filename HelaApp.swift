import SwiftUI
import CoreData

@main
struct HelaApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        print("✅ HelaApp initialized")
        print("✅ PersistenceController loaded: \(persistenceController.container.name)")
    }
    
    var body: some Scene {
        WindowGroup {
            // Use the new enhanced UI with grid layout and modern components
            MainTabViewEnhanced()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    print("✅ MainTabViewEnhanced appeared")
                }
            
            // To use the original list-based UI, uncomment this:
            // MainTabView()
            //     .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
