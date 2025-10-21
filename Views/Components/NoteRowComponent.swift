import SwiftUI

struct NoteRowComponent: View {
    let title: String
    let preview: String
    let date: Date
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            
            Text(preview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if !tags.isEmpty {
                    HStack(spacing: HelaTheme.spacingXS) {
                        ForEach(tags.prefix(2), id: \.self) { tag in
                            TagChip(text: tag)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        NoteRowComponent(
            title: "Pasta Recipe",
            preview: "Delicious homemade pasta with fresh tomatoes and basil. Serves 4 people...",
            date: Date(),
            tags: ["recipe", "italian"]
        )
        
        NoteRowComponent(
            title: "Weekly Meal Plan",
            preview: "Monday: Chicken stir-fry, Tuesday: Pasta, Wednesday: Tacos...",
            date: Date().addingTimeInterval(-86400),
            tags: ["meal_plan", "weekly"]
        )
        
        NoteRowComponent(
            title: "Shopping List",
            preview: "Milk, eggs, bread, butter, cheese, vegetables...",
            date: Date().addingTimeInterval(-172800),
            tags: ["shopping", "groceries"]
        )
    }
}

