import SwiftUI

struct MainTabViewEnhanced: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryViewGrid()
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
            
            NotesViewEnhanced()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(3)
        }
        .onAppear {
            print("✅ MainTabViewEnhanced appeared, selected tab: \(selectedTab)")
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            let tabNames = ["Library", "Capture", "Collections", "Notes"]
            print("📱 Switched to tab: \(tabNames[newValue])")
        }
    }
}

#Preview {
    MainTabViewEnhanced()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

