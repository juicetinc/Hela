import SwiftUI

struct HelaTheme {
    // MARK: - Corner Radius
    static let cornerRadiusCard: CGFloat = 12
    static let cornerRadiusChip: CGFloat = 8
    
    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    
    // MARK: - Colors
    struct Colors {
        static let primaryBlue = Color.blue
        static let primaryPurple = Color.purple
        static let itemAccent = Color.blue
        static let noteAccent = Color.purple
        static let collectionAccent = Color.purple
        
        static let backgroundPrimary = Color(.systemBackground)
        static let backgroundSecondary = Color(.systemGray6)
        static let backgroundTertiary = Color(.systemGray5)
        
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(.tertiaryLabel)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle
        static let title = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    // MARK: - Icons
    struct Icons {
        static let library = "square.grid.2x2"
        static let capture = "camera"
        static let collections = "folder"
        static let notes = "note.text"
        static let search = "magnifyingglass"
        static let add = "plus"
        static let edit = "pencil"
        static let delete = "trash"
        static let photo = "photo"
        static let folder = "folder.fill"
        static let import_ = "square.and.arrow.down"
    }
    
    // MARK: - Shadows
    static func cardShadow() -> some View {
        EmptyView()
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - View Extensions for Easy Theme Access
extension View {
    func themedCard() -> some View {
        self
            .background(HelaTheme.Colors.backgroundPrimary)
            .cornerRadius(HelaTheme.cornerRadiusCard)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func themedChip(color: Color = .blue) -> some View {
        self
            .padding(.horizontal, HelaTheme.spacingM)
            .padding(.vertical, HelaTheme.spacingS)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}

