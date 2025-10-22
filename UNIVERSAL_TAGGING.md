# 🏷️ Universal Tagging System Architecture

## Philosophy

Hela is built on a **universal, AI-first tagging system** that works for **ANY object** you photograph.

### **❌ What We DON'T Do:**

```swift
// BAD: Hardcoded, specific product checks
if image.contains("matcha") {
    tags.add("matcha")
    tags.add("beverage")
    tags.add("coffee-shop")
}
```

**Problems:**
- Only works for pre-programmed items
- Can't handle new products
- Breaks for edge cases
- Not scalable

---

### **✅ What We DO:**

```swift
// GOOD: Let AI generate flexible, contextual tags
let visionData = extractVisionData(from: image)
let intelligentTags = await appleIntelligence.generateTags(from: visionData)
```

**Benefits:**
- Works for **ANY object** (books, tools, gifts, random stuff)
- AI understands context and nuance
- Scales infinitely
- Gets smarter over time

---

## Tag Categories

Hela generates tags from **8 universal categories** that apply to everything:

### **1. 🎨 Colors**
Visual identification - works for all objects
```
Examples: "blue", "red", "multicolor", "pastel"
```

### **2. 🔨 Materials**
What it's made of - detected by Vision
```
Examples: "metal", "plastic", "fabric", "paper", "ceramic", "wood"
```

### **3. 🎯 Function**
What it does/is used for - derived intelligently
```
Examples: "wearable", "consumable", "readable", "decorative", "functional"
```

### **4. 🌍 Context**
Where/how it's used - understands environment
```
Examples: "kitchen", "bathroom", "outdoor", "workspace", "portable"
```

### **5. 📦 Object Type**
What it actually is - from Vision labels
```
Examples: "mug", "book", "plant", "tool", "electronics"
```

### **6. 📝 OCR Text**
Brands, labels, any readable text - CRITICAL for search
```
Examples: "CeraVe", "Blue Bottle", "Arduino", "Nike"
```

### **7. 🎨 Attributes**
Notable features - flexible and contextual
```
Examples: "vintage", "handmade", "portable", "rechargeable"
```

### **8. 🏷️ Broad Categories**
High-level groupings - helps with filtering
```
Examples: "food", "tech", "home", "fashion", "beauty"
```

---

## AI Prompt Design

The prompt is designed to elicit **universal, searchable tags**:

```
TAGGING RULES:
Generate UNIVERSAL, SEARCHABLE tags that help find this item later.
Include tags from these categories:
1. COLORS: Visible colors (e.g., "blue", "red", "multicolor")
2. MATERIALS: What it's made of (e.g., "fabric", "metal", "plastic")
3. FUNCTION: What it does/is for (e.g., "wearable", "consumable", "tool")
4. CONTEXT: Where/how used (e.g., "kitchen", "bathroom", "outdoor")
5. ATTRIBUTES: Notable features (e.g., "portable", "vintage", "handmade")
6. TYPE: Specific object type (e.g., "book", "mug", "plant")
7. BRAND/TEXT: Any readable text, brand names, or labels
8. CATEGORY: Broad categories (e.g., "food", "beverage", "tech")

Examples:
- Coffee mug → ["ceramic", "mug", "beverage", "kitchen", "blue", "reusable"]
- Book → ["paper", "book", "reading", "portable", "education", "red"]
- Plant → ["green", "plant", "decorative", "indoor", "living", "natural"]

RULES:
- Tags must be lowercase, singular form
- No duplicates
- 5-12 tags for maximum searchability
- Think: "What would I search for to find this again?"
```

---

## Mock Classification (Fallback)

When Apple Intelligence isn't available, we use intelligent fallbacks:

### **Material Detection:**
```swift
private func deriveUniversalMaterialTags(from objects: [String]) -> Set<String> {
    // Detects: fabric, metal, wood, plastic, paper, glass, ceramic, leather
    // Based on Vision labels, not hardcoded products
}
```

### **Function Detection:**
```swift
private func deriveUniversalFunctionTags(from objects: [String]) -> Set<String> {
    // Detects: wearable, consumable, readable, functional, entertainment, decorative
    // Based on object characteristics, not specific items
}
```

### **Context Detection:**
```swift
private func deriveUniversalContextTags(from objects: [String]) -> Set<String> {
    // Detects: kitchen, bathroom, outdoor, indoor, workspace, portable
    // Based on usage patterns, not hardcoded rules
}
```

---

## Search Strategy

Tags are designed for **natural, intuitive search**:

### **By Color:**
```
Search: "blue"
→ Find all blue items (mug, shirt, book, electronics)
```

### **By Material:**
```
Search: "ceramic"
→ Find all ceramic items (plates, mugs, vases)
```

### **By Function:**
```
Search: "consumable"
→ Find items that run out (food, skincare, supplies)
```

### **By Context:**
```
Search: "kitchen"
→ Find all kitchen items (utensils, food, appliances)
```

### **By Brand:**
```
Search: "CeraVe"
→ Find all CeraVe products (from OCR text!)
```

### **By Type:**
```
Search: "book"
→ Find all books
```

### **Multi-Tag Search:**
```
Search: "blue ceramic kitchen"
→ Find blue ceramic items used in kitchen
```

---

## Why This Scales

### **1. No Hardcoding**
- Works for new products automatically
- AI adapts to any object
- No maintenance required

### **2. Context-Aware**
- AI understands nuance
- Generates relevant tags based on what it sees
- Handles edge cases intelligently

### **3. Extensible**
- Easy to add new tag categories
- Prompt can be refined over time
- Fallbacks ensure reliability

### **4. Privacy-First**
- On-device processing (Apple Intelligence)
- No data leaves your device
- No cloud dependencies

---

## Example Outputs

### **Unconventional Items:**

**Random gift wrap:**
```json
{
  "title": "Colorful Gift Wrap",
  "tags": ["paper", "colorful", "decorative", "gift", "pattern", "portable"]
}
```

**Arduino kit:**
```json
{
  "title": "Arduino Development Board",
  "tags": ["blue", "electronic", "tool", "Arduino", "tech", "workspace", "functional"]
}
```

**Vintage camera:**
```json
{
  "title": "Black Vintage Camera",
  "tags": ["black", "metal", "camera", "vintage", "functional", "portable", "photography"]
}
```

**Handmade scarf:**
```json
{
  "title": "Knitted Wool Scarf",
  "tags": ["fabric", "wool", "wearable", "handmade", "winter", "fashion", "soft"]
}
```

---

## Future Improvements

### **1. Visual Search**
Use embeddings to find visually similar items:
```
"Find items that look like this"
```

### **2. Smart Collections**
Auto-group related items:
```
"Coffee Shop Visits", "Skincare Routine", "Gift Ideas for Mom"
```

### **3. Relationship Mapping**
Understand connections:
```
"Show all items I bought at Target"
"Show all electronics in my bedroom"
```

### **4. Natural Language Queries**
Let AI interpret complex searches:
```
"Show me blue kitchen items that I need to restock"
```

### **5. Tag Refinement**
Learn from user behavior:
```
User always searches "tech" instead of "electronic"
→ AI starts using "tech" more often
```

---

## Technical Implementation

### **Data Flow:**

```
Photo → Vision Framework → [objects, colors, text]
                          ↓
                    Apple Intelligence
                          ↓
              Generate universal tags
                          ↓
              ["ceramic", "mug", "blue", "kitchen", ...]
                          ↓
                    Save to Core Data
                          ↓
                 Instant searchability! 🎉
```

### **Key Files:**

- `AIClassifier.swift`: Prompt engineering + tag generation
- `VisionAnalyzer.swift`: Vision Framework integration
- `InventoryStore.swift`: Search logic
- `InventoryItem.xcdatamodeld`: Tag storage

---

## Conclusion

**Hela's universal tagging system is:**
- ✅ AI-first (not rule-based)
- ✅ Works for ANY object
- ✅ Privacy-respecting
- ✅ Infinitely scalable
- ✅ Search-optimized

**The key insight:** Let the AI do what it's good at (understanding context and generating relevant tags), and build the infrastructure to make those tags searchable and useful.

---

**This is the future of personal inventory tracking. 🚀**

