# Debugging Instructions - Blank White Screen

## Current State
The app has been modified with diagnostic logging to help identify the blank screen issue.

## What Changed
1. Added debug logging to `HelaApp.swift`
2. Added debug logging to `PersistenceController.swift`
3. Created `DiagnosticView.swift` - a simple test view
4. Temporarily switched app entry point to use DiagnosticView

## Steps to Debug

### 1. Rebuild the App
```bash
# In Xcode
Product → Clean Build Folder (Cmd+Shift+K)
Product → Run (Cmd+R)
```

### 2. Check Console Output
Look for these messages in the Xcode console:

**Good output:**
```
🔵 Initializing PersistenceController (inMemory: false)
🔵 Loading persistent stores...
✅ Core Data store loaded successfully
✅ Store URL: file://...
✅ PersistenceController initialization complete
✅ HelaApp initialized
✅ Main view appeared
✅ DiagnosticView appeared
```

**Problem indicators:**
```
❌ FATAL: Failed to load Core Data stack: ...
❌ Store description: ...
```

### 3. Verify Target Membership

**Critical Files Must Be in Target:**
- [ ] `Hela.xcdatamodeld` (Core Data model)
- [ ] All `.swift` files in project
- [ ] `Info.plist`

**How to check:**
1. Select file in Project Navigator
2. Open File Inspector (Option+Cmd+1)
3. Under "Target Membership", ensure your app target is checked

### 4. Common Issues & Solutions

#### Issue A: Core Data Model Not Found
**Symptoms:** Crash on launch, blank screen, console shows "Failed to load Core Data stack"

**Fix:**
1. Select `Hela.xcdatamodeld` folder
2. File Inspector → Target Membership
3. Check your app target
4. Clean and rebuild

#### Issue B: Missing Required Files
**Symptoms:** Compilation errors, "Cannot find type..."

**Fix:**
1. Add missing files to target:
   - DiagnosticView.swift
   - CollectionsView.swift
   - UnifiedSearchView.swift
   - QueryPlanner.swift
   - SearchResult.swift
2. Rebuild

#### Issue C: Simulator Issues
**Fix:**
```bash
# Reset simulator
Device → Erase All Content and Settings...
# Then rebuild and run
```

## Testing the Diagnostic View

When the app runs with DiagnosticView:

1. **You should see:**
   - "Hela Diagnostic" title
   - Green checkmarks
   - "Test Core Data" button
   - "Go to Main App" button

2. **Click "Test Core Data"**
   - Console should show: `✅ Core Data test passed - item saved`
   - If it fails, Core Data is the issue

3. **Click "Go to Main App"**
   - Navigates to the full MainTabView
   - If this is blank, the issue is in one of the tab views

## Once Working: Restore Normal App

Edit `HelaApp.swift` and change:
```swift
// FROM:
NavigationStack {
    DiagnosticView()
}

// TO:
MainTabView()
```

## Additional Debugging

### Enable verbose Core Data logging:
Add to scheme in Xcode:
```
Edit Scheme → Run → Arguments → Arguments Passed On Launch
-com.apple.CoreData.SQLDebug 1
```

### Check file permissions:
```bash
ls -la ~/Library/Developer/CoreSimulator/
```

### Verify Xcode configuration:
1. Select project in navigator
2. Select app target
3. General tab:
   - Deployment Target: iOS 17.0 or higher
   - Main Interface: Leave blank (SwiftUI)
4. Build Settings:
   - Search "Swift"
   - Swift Language Version: Swift 5

## Still Having Issues?

1. **Check Xcode console** - Copy the exact error message
2. **Check Issue Navigator** (Cmd+5) - Look for build errors
3. **Try creating a new target** - Sometimes Xcode project gets corrupted
4. **Verify all imports** - Make sure no missing modules

## Contact Points
- Console output from running app
- Build errors from Issue Navigator
- Specific error messages

---
Last updated: October 21, 2025

