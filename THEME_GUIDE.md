# Hela Theme Guide

## Overview

The `HelaTheme` provides a centralized design system for consistent styling across the Hela app.

## Usage

### Import
```swift
import SwiftUI
// HelaTheme is automatically available
```

## Design Tokens

### 📏 Spacing

```swift
HelaTheme.spacingXS    // 4pt  - Tight spacing
HelaTheme.spacingS     // 8pt  - Small spacing
HelaTheme.spacingM     // 12pt - Medium spacing
HelaTheme.spacingL     // 16pt - Large spacing (default padding)
HelaTheme.spacingXL    // 24pt - Extra large spacing (section gaps)
```

**Example:**
```swift
VStack(spacing: HelaTheme.spacingL) {
    Text("Title")
    Text("Body")
}
.padding(HelaTheme.spacingM)
```

### 🎨 Corner Radius

```swift
HelaTheme.cornerRadiusCard  // 12pt - For cards, images
HelaTheme.cornerRadiusChip  // 8pt  - For tags, badges, small elements
```

**Example:**
```swift
Image(uiImage: photo)
    .cornerRadius(HelaTheme.cornerRadiusCard)

Text("Tag")
    .background(
        RoundedRectangle(cornerRadius: HelaTheme.cornerRadiusChip)
    )
```

### 🎨 Colors

```swift
// Primary Colors
HelaTheme.Colors.primaryBlue      // Blue accent
HelaTheme.Colors.primaryPurple    // Purple accent
HelaTheme.Colors.itemAccent       // For items (blue)
HelaTheme.Colors.noteAccent       // For notes (purple)
HelaTheme.Colors.collectionAccent // For collections (purple)

// Backgrounds
HelaTheme.Colors.backgroundPrimary    // System background
HelaTheme.Colors.backgroundSecondary  // Light gray (.systemGray6)
HelaTheme.Colors.backgroundTertiary   // Medium gray (.systemGray5)

// Text
HelaTheme.Colors.textPrimary    // Primary text
HelaTheme.Colors.textSecondary  // Secondary text
HelaTheme.Colors.textTertiary   // Tertiary text
```

**Example:**
```swift
Text("Category")
    .foregroundStyle(HelaTheme.Colors.textSecondary)
    .background(HelaTheme.Colors.backgroundSecondary)
```

### 📝 Typography

```swift
HelaTheme.Typography.largeTitle  // Largest headings
HelaTheme.Typography.title       // Page titles
HelaTheme.Typography.title2      // Section titles
HelaTheme.Typography.title3      // Subsection titles
HelaTheme.Typography.headline    // Important text
HelaTheme.Typography.body        // Body text
HelaTheme.Typography.callout     // Callouts
HelaTheme.Typography.subheadline // Secondary headings
HelaTheme.Typography.footnote    // Footnotes
HelaTheme.Typography.caption     // Captions
HelaTheme.Typography.caption2    // Small captions
```

**Example:**
```swift
Text("Welcome")
    .font(HelaTheme.Typography.title)

Text("Description")
    .font(HelaTheme.Typography.body)
```

### 🔖 Icons

```swift
HelaTheme.Icons.library     // "square.grid.2x2"
HelaTheme.Icons.capture     // "camera"
HelaTheme.Icons.collections // "folder"
HelaTheme.Icons.notes       // "note.text"
HelaTheme.Icons.search      // "magnifyingglass"
HelaTheme.Icons.add         // "plus"
HelaTheme.Icons.edit        // "pencil"
HelaTheme.Icons.delete      // "trash"
HelaTheme.Icons.photo       // "photo"
HelaTheme.Icons.folder      // "folder.fill"
HelaTheme.Icons.import_     // "square.and.arrow.down"
```

**Example:**
```swift
Image(systemName: HelaTheme.Icons.library)
    .font(.title)
```

## View Extensions

### Themed Card

Apply consistent card styling:

```swift
VStack {
    Text("Content")
}
.themedCard()
```

Equivalent to:
```swift
.background(HelaTheme.Colors.backgroundPrimary)
.cornerRadius(HelaTheme.cornerRadiusCard)
.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
```

### Themed Chip

Apply consistent chip/badge styling:

```swift
Text("Tag")
    .themedChip()  // Blue by default

Text("Note")
    .themedChip(color: .purple)
```

## Common Patterns

### Category Badge
```swift
Text("BAG")
    .font(HelaTheme.Typography.caption)
    .fontWeight(.semibold)
    .foregroundStyle(.white)
    .padding(.horizontal, HelaTheme.spacingM)
    .padding(.vertical, HelaTheme.spacingS)
    .background(
        Capsule()
            .fill(HelaTheme.Colors.itemAccent)
    )
```

### Empty State
```swift
VStack(spacing: HelaTheme.spacingL) {
    Image(systemName: HelaTheme.Icons.photo)
        .font(.system(size: 64))
        .foregroundStyle(HelaTheme.Colors.textSecondary)
    
    Text("No Items")
        .font(HelaTheme.Typography.title2)
        .fontWeight(.semibold)
    
    Text("Capture items to see them here")
        .font(HelaTheme.Typography.subheadline)
        .foregroundStyle(HelaTheme.Colors.textSecondary)
}
.padding(HelaTheme.spacingXL)
```

### Filter Chip
```swift
Button {
    // action
} label: {
    Text("All")
        .font(HelaTheme.Typography.subheadline)
        .fontWeight(.medium)
        .padding(.horizontal, HelaTheme.spacingL)
        .padding(.vertical, HelaTheme.spacingS)
        .background(
            Capsule()
                .fill(isSelected ? HelaTheme.Colors.primaryBlue : HelaTheme.Colors.backgroundSecondary)
        )
        .foregroundStyle(isSelected ? .white : HelaTheme.Colors.textPrimary)
}
```

### Card Layout
```swift
VStack(alignment: .leading, spacing: HelaTheme.spacingL) {
    // Header
    Text("Title")
        .font(HelaTheme.Typography.headline)
    
    // Content
    Text("Body text")
        .font(HelaTheme.Typography.body)
        .foregroundStyle(HelaTheme.Colors.textSecondary)
}
.padding(HelaTheme.spacingL)
.background(HelaTheme.Colors.backgroundPrimary)
.cornerRadius(HelaTheme.cornerRadiusCard)
.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
```

## Migration Guide

### Before:
```swift
VStack(spacing: 16) {
    Text("Title")
        .font(.headline)
}
.padding(12)
.cornerRadius(8)
.background(Color(.systemGray6))
```

### After:
```swift
VStack(spacing: HelaTheme.spacingL) {
    Text("Title")
        .font(HelaTheme.Typography.headline)
}
.padding(HelaTheme.spacingM)
.cornerRadius(HelaTheme.cornerRadiusChip)
.background(HelaTheme.Colors.backgroundSecondary)
```

## Benefits

✅ **Consistency** - Same spacing, colors, and styles everywhere
✅ **Maintainability** - Change once, update everywhere
✅ **Readability** - Semantic names make code self-documenting
✅ **Scalability** - Easy to add new design tokens
✅ **Accessibility** - System fonts and colors adapt to user preferences

## Best Practices

1. **Always use theme tokens** instead of hardcoded values
2. **Use semantic names** - `HelaTheme.spacingL` not `16`
3. **Leverage view extensions** - `.themedCard()` instead of manual styling
4. **Keep it DRY** - Extract common patterns into extensions
5. **Update the theme** - When adding new patterns, add to HelaTheme

## Examples in Codebase

✅ **LibraryView** - Filter chips, spacing, colors
✅ **ItemDetailView** - Card corners, shadows, spacing
✅ **More to come** - Gradually migrate all views

---

Created: October 21, 2025
Last Updated: October 21, 2025

