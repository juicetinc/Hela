# Share Extension Implementation Guide

## P6 - Share Extension (HelaShare)

The Share Extension for accepting text and images from Apple Notes requires creating a new app extension target in Xcode. This cannot be done through file editing alone.

### Steps to Implement:

1. **Create Share Extension Target**
   - In Xcode: File → New → Target → Share Extension
   - Name: `HelaShare`
   - Language: Swift
   - Activate the scheme when prompted

2. **Configure Info.plist**
   Add to the Share Extension's Info.plist:
   ```xml
   <key>NSExtensionActivationRule</key>
   <dict>
       <key>NSExtensionActivationSupportsText</key>
       <true/>
       <key>NSExtensionActivationSupportsImageWithMaxCount</key>
       <integer>1</integer>
   </dict>
   ```

3. **Create ShareViewController.swift**
   Replace the default ShareViewController with:
   
   ```swift
   import UIKit
   import Social
   import CoreData
   
   class ShareViewController: UIViewController {
       private var sharedText: String?
       private var sharedImage: UIImage?
       
       override func viewDidLoad() {
           super.viewDidLoad()
           extractSharedContent()
       }
       
       private func extractSharedContent() {
           guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
                 let itemProviders = extensionItem.attachments else {
               return
           }
           
           for provider in itemProviders {
               // Handle text
               if provider.hasItemConformingToTypeIdentifier("public.plain-text") {
                   provider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { [weak self] (item, error) in
                       if let text = item as? String {
                           self?.sharedText = text
                           self?.processSharedContent()
                       }
                   }
               }
               
               // Handle images
               if provider.hasItemConformingToTypeIdentifier("public.image") {
                   provider.loadItem(forTypeIdentifier: "public.image", options: nil) { [weak self] (item, error) in
                       if let url = item as? URL,
                          let imageData = try? Data(contentsOf: url),
                          let image = UIImage(data: imageData) {
                           self?.sharedImage = image
                       }
                   }
               }
           }
       }
       
       private func processSharedContent() {
           guard let text = sharedText else { return }
           
           Task {
               // Import using NoteImporter
               let noteData = await NoteImporter.shared.importNote(text: text)
               
               // Save to shared Core Data store
               let context = PersistenceController.shared.container.viewContext
               InventoryStore.shared.saveNote(
                   title: noteData.title,
                   body: noteData.body,
                   category: noteData.category,
                   tags: noteData.tags,
                   attributes: [:],
                   context: context
               )
               
               // Close extension
               await MainActor.run {
                   self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
               }
           }
       }
   }
   ```

4. **Configure App Groups**
   - Enable App Groups capability in both main app and extension
   - Create group: `group.com.yourcompany.hela`
   - Update PersistenceController to use the shared container:
   
   ```swift
   let containerURL = FileManager.default.containerURL(
       forSecurityApplicationGroupIdentifier: "group.com.yourcompany.hela"
   )!
   let storeURL = containerURL.appendingPathComponent("Hela.sqlite")
   ```

5. **Test the Extension**
   - Share text or image from Notes app
   - Select "HelaShare" from share sheet
   - Verify note is saved in Hela app

## Alternative Approach (Implemented)

Since Share Extension requires Xcode project configuration, we've implemented an alternative "Import Note" feature in the Notes tab:

- ✅ Paste text directly into the app
- ✅ Import from .txt or .html files
- ✅ Automatic classification (recipe, meal_plan, or note)
- ✅ Automatic tagging with "imported" and "apple_notes"

This provides similar functionality without requiring the Share Extension setup.

