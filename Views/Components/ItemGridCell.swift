import SwiftUI

struct ItemGridCell: View {
    let image: Image?
    let title: String
    let tags: [String]
    let quantity: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: HelaTheme.spacingS) {
            ZStack(alignment: .topTrailing) {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: HelaTheme.cornerRadiusCard))
                } else {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HelaTheme.cornerRadiusCard))
                }
                
                if quantity > 1 {
                    Text("×\(quantity)")
                        .font(.caption2.monospacedDigit())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(6)
                }
            }
            
            Text(title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.primary)
            
            if !tags.isEmpty {
                HStack(spacing: HelaTheme.spacingXS) {
                    ForEach(tags.prefix(2), id: \.self) { tag in
                        TagChip(text: tag)
                    }
                }
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
        ItemGridCell(
            image: Image(systemName: "bag.fill"),
            title: "Leather Handbag",
            tags: ["leather", "vintage"],
            quantity: 1
        )
        
        ItemGridCell(
            image: nil,
            title: "Blue Tote",
            tags: ["canvas", "large"],
            quantity: 3
        )
        
        ItemGridCell(
            image: Image(systemName: "fork.knife"),
            title: "Pasta Recipe",
            tags: ["italian", "dinner"],
            quantity: 1
        )
    }
    .padding()
}

