  # Hela UI Components Guide

## Overview

The Hela app now features a modern, Apple-style UI with reusable components inspired by Photos, Notes, and other native iOS apps.

## 🎨 Component Library

### 1. TagChip

A small, rounded chip for displaying tags and categories.

**Location:** `Views/Components/TagChip.swift`

**Usage:**
```swift
TagChip(text: "leather")
```

**Features:**
- Subtle border with secondary background
- Auto-truncates long text
- Consistent with system design

**Preview:**
```
[leather] [vintage] [imported]
```

---

### 2. FlowLayout

A flexible layout that wraps children to new lines like UICollectionView.

**Location:** `Views/Components/FlowLayout.swift`

**Usage:**
```swift
FlowLayoutSimple(spacing: 6) {
    ForEach(tags, id: \.self) { tag in
        TagChip(text: tag)
    }
}
```

**Features:**
- Auto-wraps to new lines
- Configurable spacing
- Works with any child views

**Use Cases:**
- Tag displays
- Filter chips
- Any collection that needs wrapping

---

### 3. ItemGridCell

Photos-style grid cell for items with image, title, and tags.

**Location:** `Views/Components/ItemGridCell.swift`

**Usage:**
```swift
ItemGridCell(
    image: Image(uiImage: photo),
    title: "Leather Handbag",
    tags: ["leather", "vintage"],
    quantity: 2
)
```

**Features:**
- 150pt tall image with rounded corners
- Quantity badge (×N) if > 1
- Shows up to 2 tags
- Graceful nil image handling

**Layout:**
```
┌───────────────┐
│               │
│     IMAGE     │  ×2 ← quantity badge
│               │
├───────────────┤
│ Leather Hand… │
│ [leather][vintage] │
└───────────────┘
```

---

### 4. NoteRowComponent

Notes-style row for list items.

**Location:** `Views/Components/NoteRowComponent.swift`

**Usage:**
```swift
NoteRowComponent(
    title: "Pasta Recipe",
    preview: "Delicious homemade pasta...",
    date: Date(),
    tags: ["recipe", "italian"]
)
```

**Features:**
- Bold title
- 2-line preview text
- Date on left, tags on right
- Secondary text styling

**Layout:**
```
Pasta Recipe
Delicious homemade pasta with fresh tomatoes...
Oct 21 • [recipe][italian]
```

---

### 5. FilterSheet

Bottom sheet for filtering and sorting.

**Location:** `Views/Components/FilterSheet.swift`

**Usage:**
```swift
.sheet(isPresented: $showFilters) {
    FilterSheet(
        selectedCategory: $category,
        selectedCollection: $collection,
        sortBy: $sort,
        collections: ["All", "Kitchen", "Closet"]
    )
    .presentationDetents([.medium])
}
```

**Features:**
- Category picker
- Collection picker (conditional)
- Sort picker
- Reset button
- Medium presentation detent

---

## 📱 Screen Implementations

### LibraryViewGrid

Modern grid-based library view with Photos-style layout.

**Location:** `Views/LibraryViewGrid.swift`

**Features:**
- Adaptive grid (160pt minimum cell width)
- Search bar in navigation drawer
- Filter button (funnel icon)
- Unified search button
- Empty states
- Filter + sort + search integration

**Layout:**
```
┌─────────────────────────────┐
│ ⊙ Hela              🔍 ≡   │ ← Navigation
│ Search...                   │ ← Search drawer
├─────────────────────────────┤
│ ┌────┐ ┌────┐ ┌────┐      │
│ │IMG1│ │IMG2│ │IMG3│      │ ← Grid
│ └────┘ └────┘ └────┘      │
│ ┌────┐ ┌────┐             │
│ │IMG4│ │IMG5│             │
│ └────┘ └────┘             │
└─────────────────────────────┘
```

**Filtering:**
- Category: All, Bag, Recipe, etc.
- Collection: Dynamically loaded
- Sort: Newest, A-Z, Most Qty, Color
- Search: Title, summary, tags, OCR text

---

### ItemDetailViewEnhanced

Hero image detail view with full-width photo header.

**Location:** `Views/ItemDetailViewEnhanced.swift`

**Features:**
- Full-width 300pt hero image
- Ignores safe area at top
- Inline toolbar
- Flow layout for tags
- Attribute list with dividers
- Metadata section
- Edit sheet integration

**Layout:**
```
┌─────────────────────────────┐
│                             │
│       HERO IMAGE            │ ← 300pt
│                             │
├─────────────────────────────┤
│ Title                       │
│ Summary text here...        │
│                             │
│ [tag1] [tag2] [tag3]       │
│                             │
│ ─────────────────────       │
│ Attributes                  │
│ Color            Blue       │
│ Material         Leather    │
│ ─────────────────────       │
│ Metadata                    │
│ Quantity         2          │
│ Collection       Kitchen    │
│ Created          Oct 21...  │
└─────────────────────────────┘
```

---

### NotesViewEnhanced

Notes-style list view with preview text.

**Location:** `Views/NotesViewEnhanced.swift`

**Features:**
- Plain list style
- Notes-style rows with preview
- Search integration
- Import button (download icon)
- New note button (pencil icon)
- Swipe to delete

**Layout:**
```
┌─────────────────────────────┐
│ ↓ Notes            ✎       │
│ Search notes...             │
├─────────────────────────────┤
│ Pasta Recipe                │
│ Delicious homemade pasta... │
│ Oct 21 • [recipe][italian]  │
├─────────────────────────────┤
│ Shopping List               │
│ Milk, eggs, bread, butter...│
│ Oct 20 • [shopping]         │
└─────────────────────────────┘
```

---

### MainTabViewEnhanced

Main app container with 4 tabs.

**Location:** `MainTabViewEnhanced.swift`

**Tabs:**
1. **Library** - Grid view (square.grid.2x2)
2. **Capture** - Camera (camera)
3. **Collections** - Folders (folder)
4. **Notes** - Notes list (note.text)

---

## 🎯 Design Patterns

### Empty States

All views include proper empty states:

```swift
VStack(spacing: HelaTheme.spacingL) {
    Image(systemName: "icon")
        .font(.system(size: 64))
        .foregroundStyle(.secondary)
    
    Text("Title")
        .font(HelaTheme.Typography.title2)
        .fontWeight(.semibold)
    
    Text("Description")
        .font(HelaTheme.Typography.subheadline)
        .foregroundStyle(.secondary)
}
```

### Grid Layouts

Use adaptive grid items for responsive grids:

```swift
LazyVGrid(
    columns: [GridItem(.adaptive(minimum: 160), spacing: 12)],
    spacing: 12
) {
    ForEach(items) { item in
        ItemGridCell(...)
    }
}
```

### Navigation Links

Make entire cells tappable with buttonStyle:

```swift
NavigationLink {
    DetailView()
} label: {
    ItemGridCell(...)
}
.buttonStyle(.plain)
```

### Bottom Sheets

Use presentation detents for thumb-friendly sheets:

```swift
.sheet(isPresented: $show) {
    FilterSheet(...)
        .presentationDetents([.medium, .large])
}
```

---

## 🔄 Migration from Original UI

### Before (List-based):
```swift
List {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}
```

### After (Grid-based):
```swift
LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))]) {
    ForEach(items) { item in
        ItemGridCell(
            image: itemImage(item),
            title: item.title,
            tags: item.tags,
            quantity: item.quantity
        )
    }
}
```

---

## 🎨 Visual Hierarchy

### Typography Scale
- **Title** - Main screen titles
- **Title2** - Section headers, card titles
- **Headline** - Important text, list item titles
- **Body** - Standard text
- **Subheadline** - Secondary info
- **Caption** - Tags, metadata

### Color Usage
- **Primary Blue** - Items, filters, CTAs
- **Purple** - Notes, collections
- **Secondary** - Muted text, borders
- **System Gray 6** - Backgrounds, placeholders

### Spacing
- **XS (4pt)** - Tight spacing between tags
- **S (8pt)** - Row content spacing
- **M (12pt)** - Card internal padding
- **L (16pt)** - Default padding
- **XL (24pt)** - Section gaps

---

## 🚀 Quick Start

### Use Existing Components
```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        VStack {
            // Use pre-built components
            TagChip(text: "example")
            
            // Use with FlowLayout
            FlowLayoutSimple(spacing: 6) {
                ForEach(tags) { TagChip(text: $0) }
            }
        }
    }
}
```

### Create New Components
Follow the established patterns:
1. Use `HelaTheme` for all spacing/colors
2. Include previews
3. Make reusable and configurable
4. Support empty/nil states
5. Use semantic colors

---

## 📚 Resources

- **HelaTheme.swift** - Design tokens
- **THEME_GUIDE.md** - Theme usage guide
- **Components/** - Reusable UI components
- **IMPLEMENTATION_SUMMARY.md** - Feature docs

---

## ✅ Checklist for New Components

- [ ] Uses HelaTheme for spacing/colors
- [ ] Has SwiftUI preview
- [ ] Handles empty/nil states
- [ ] Supports Dynamic Type
- [ ] Works in light/dark mode
- [ ] Documented in this guide
- [ ] Reusable across views

---

Created: October 21, 2025
Last Updated: October 21, 2025
Version: 2.0 (Enhanced UI)

