import SwiftUI
import CoreData

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "square.grid.2x2")
                }
                .tag(0)
            
            CaptureView()
                .tabItem {
                    Label("Capture", systemImage: "camera")
                }
                .tag(1)
            
            CollectionsView()
                .tabItem {
                    Label("Collections", systemImage: "folder")
                }
                .tag(2)
            
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(3)
        }
        .onAppear {
            print("✅ MainTabView appeared, selected tab: \(selectedTab)")
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            let tabNames = ["Library", "Capture", "Collections", "Notes"]
            print("📱 Switched to tab: \(tabNames[newValue])")
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
