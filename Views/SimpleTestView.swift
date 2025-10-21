import SwiftUI

/// Ultra-simple view to test if SwiftUI rendering works
struct SimpleTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Hela is Working!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("If you can see this, SwiftUI is rendering correctly.")
                .multilineTextAlignment(.center)
                .padding()
            
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
            
            Button("Test Button") {
                print("Button tapped!")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            print("✅ SimpleTestView appeared")
        }
    }
}

#Preview {
    SimpleTestView()
}

