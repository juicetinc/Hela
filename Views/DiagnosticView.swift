import SwiftUI
import CoreData

/// Simple diagnostic view to help debug blank screen issues
struct DiagnosticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hela Diagnostic")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("✅ SwiftUI is working")
                .foregroundStyle(.green)
            
            Text("✅ Views are rendering")
                .foregroundStyle(.green)
            
            Button("Test Core Data") {
                testCoreData()
            }
            .buttonStyle(.bordered)
            
            NavigationLink("Go to Main App") {
                MainTabView()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            print("✅ DiagnosticView appeared")
        }
    }
    
    private func testCoreData() {
        print("🔵 Testing Core Data...")
        
        let testItem = Item(context: viewContext)
        testItem.id = UUID()
        testItem.title = "Test Item"
        testItem.createdAt = Date()
        
        do {
            try viewContext.save()
            print("✅ Core Data test passed - item saved")
        } catch {
            print("❌ Core Data test failed: \(error)")
        }
    }
}

#Preview {
    DiagnosticView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

