import SwiftUI

struct TagChip: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: HelaTheme.cornerRadiusChip))
            .overlay(
                RoundedRectangle(cornerRadius: HelaTheme.cornerRadiusChip)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 0.5)
            )
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }
}

#Preview {
    HStack {
        TagChip(text: "leather")
        TagChip(text: "vintage")
        TagChip(text: "bag")
    }
    .padding()
}

