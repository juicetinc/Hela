# Hela

**One-tap capture + instant organization.**

A SwiftUI iOS app that uses on-device Vision and Apple Intelligence to automatically organize your photos and notes.

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 5.9+

## Features

- **Library Tab**: Browse all captured items
  - List view with thumbnails from Photos library
  - Search by title, summary, or tags (case-insensitive)
  - Filter by 9 categories
  - Swipe to delete
  - All queries run locally

- **Capture Tab**: One-tap photo capture
  - Select photos from library with PhotosPicker
  - Real Vision analysis (VNRecognizeObjectsRequest + VNRecognizeTextRequest)
  - On-device AI classification using Foundation Models
  - Editable confirmation sheet before saving
  - Collection and quantity tracking
  - Saves to both Core Data and Photos library

- **Notes Tab**: Text note management
  - Create and organize text notes
  - Searchable by title and content
  - Category tagging

## Architecture

### Views
- `MainTabView.swift`: Root tab view (Library, Capture, Notes)
- `CaptureView.swift`: Photo selection with confirmation sheet
- `LibraryView.swift`: Item list with search and category filters
- `ItemDetailView.swift`: Full item details with metadata
- `NotesView.swift`: Note list and creation

### ViewModels
- `CaptureViewModel.swift`: Manages capture flow with editable fields

### Models
- `VisionSummary.swift`: Vision analysis results (objects, OCR, colors)
- `ItemRecord.swift`: AI classification output (title, summary, category, tags, attributes)
- `AnyCodable.swift`: Type-erased Codable for flexible attributes

### Services
- `VisionAnalyzer.swift`: Apple Vision framework integration
  - Object detection with confidence scores
  - OCR text recognition
  - Dominant color extraction (3-5 colors)

- `AIClassifier.swift`: On-device AI classification
  - Foundation Models API (iOS 18+)
  - Structured JSON output
  - 8 categories: general, bag, recipe, receipt, fashion, decor, document, note
  - 3-10 lowercase singular tags
  - Structured attributes

- `PhotoLibraryService.swift`: Photos framework integration
  - Saves to Photos library
  - Returns PHAsset localIdentifier
  - Loads thumbnails and full images

- `NoteImporter.swift`: Text note processing stub
  - Format detection
  - Title extraction
  - Keyword analysis

### Utilities
- `DominantColor.swift`: Color analysis utility
  - HSB-based color categorization
  - Returns 3-5 simple color names

### Data Layer
- `PersistenceController.swift`: Core Data stack management
- `InventoryStore.swift`: CRUD operations for items and notes

## Core Data Model

### Item Entity
- `id`: UUID
- `createdAt`: Date
- `imageLocalId`: String (PHAsset identifier)
- `imageData`: Binary (compressed JPEG)
- `title`: String
- `summary`: String  
- `category`: String (general|bag|recipe|receipt|fashion|decor|document|note)
- `tagsCSV`: String (comma-separated)
- `dominantColorsJSON`: String (JSON array)
- `attributesJSON`: String (JSON dictionary)
- `ocrText`: String (recognized text)
- `collection`: String (optional grouping)
- `quantity`: Int16 (default 1)
- `notes`: String (optional)
- `classification`: String (legacy)

### NoteEntry Entity
- `id`: UUID
- `createdAt`: Date
- `title`: String
- `body`: String
- `category`: String
- `tagsCSV`: String
- `attributesJSON`: String

## Data Flow

1. User selects photo → PhotosPicker
2. Vision analysis → `VisionSummary` (objects, OCR, colors)
3. AI classification → `ItemRecord` (title, summary, category, tags, attributes)
4. Confirmation sheet → User edits fields (title, summary, category, tags, collection, quantity)
5. Save to Photos → Get PHAsset localIdentifier
6. Save to Core Data → Item with all fields
7. Show "Saved" toast
8. Item appears in Library

## Categories

Hela supports 8 item categories:
- **general**: Miscellaneous items
- **bag**: Bags, purses, backpacks
- **recipe**: Recipe cards, food photos
- **receipt**: Receipts, invoices
- **fashion**: Clothing, accessories
- **decor**: Home decor, furniture
- **document**: Documents, papers
- **note**: Text notes, memos

## Privacy & Permissions

- **Camera**: For future camera capture feature
- **Photo Library Access**: To select photos
- **Photo Library Add**: To save analyzed photos

All processing runs on-device. No data leaves your phone.

## Project Structure

```
Hela/
├── HelaApp.swift                  # App entry point
├── MainTabView.swift              # Tab navigation
├── Info.plist                     # Permissions & config
├── Views/
│   ├── CaptureView.swift         # Photo capture & confirmation
│   ├── LibraryView.swift         # Item list with filters
│   ├── ItemDetailView.swift     # Item details
│   └── NotesView.swift           # Note management
├── ViewModels/
│   └── CaptureViewModel.swift    # Capture state & logic
├── Models/
│   ├── VisionSummary.swift       # Vision results
│   ├── ItemRecord.swift          # Classification output
│   └── AnyCodable.swift          # Flexible Codable
├── Services/
│   ├── VisionAnalyzer.swift      # Vision framework
│   ├── AIClassifier.swift        # On-device AI
│   ├── PhotoLibraryService.swift # Photos integration
│   └── NoteImporter.swift        # Note processing
├── Utilities/
│   └── DominantColor.swift       # Color extraction
└── Data/
    ├── PersistenceController.swift # Core Data stack
    ├── InventoryStore.swift       # Data access layer
    └── Hela.xcdatamodeld/         # Core Data model
```

## Building

No third-party dependencies required. All frameworks are part of iOS SDK:
- SwiftUI
- PhotosUI
- CoreData
- Vision
- CoreML
- Photos

```bash
open Hela.xcodeproj
# Select target device (iOS 18+)
# Build and run
```

## Implementation Status

✅ **Fully Implemented:**
- Vision analysis (objects, OCR, colors)
- Photo library integration
- Confirmation sheet with editable fields
- Core Data with Item and NoteEntry entities
- Search and filtering
- Collection and quantity tracking
- Notes tab with basic CRUD

⚠️ **Stub/Mock:**
- Apple Intelligence API (structure ready, waiting for production API)
- NoteImporter text processing

## Future Enhancements

- Camera capture (currently photo picker only)
- Advanced note parsing with NLP
- Item editing after save
- Data export (CSV, JSON)
- Cloud sync (CloudKit)
- Share extension
- Widgets
- Barcode/QR scanning

## License

Created for demonstration purposes.
