# 📸 Hela: Universal Personal Inventory Tracker

## What is Hela?

**Hela is a universal photo-based inventory app powered by Apple Intelligence.**

Instead of manually typing notes about things you own, see, buy, or want to remember:
- 📸 **Take a photo**
- 🤖 **AI auto-extracts**: title, description, searchable tags
- 🔍 **Search instantly**: Find anything by what it looks like, what it's made of, or what it does

---

## 🎯 Why Hela Exists

### **Before (Manual Apple Notes):**
```
📝 Tedious manual typing:
"Blue Bottle - Iced Matcha Latte - 5 stars"
"CeraVe Moisturizing Cream - Restock when low"
"Muji Black Pen - Buy more"
"Arduino Uno Kit - In storage box"
"Mom's Birthday Gift Ideas - Floral scarf"
```

### **After (Hela with AI):**
```
📸 Just take a photo:
→ AI auto-generates title, description, tags
→ Search: "blue moisturizer", "electronics", "gift ideas"
→ Find anything instantly
```

---

## ✨ Universal Use Cases

Hela works for **ANYTHING** you want to track:

### **1. 🛒 Consumption & Restocking**
- Coffee/tea purchases → Track favorite drinks
- Skincare products → Remember what works
- Household items → Know when to restock
- Food & beverages → Rate and remember

**Tags**: `consumable`, `repurchase`, brand names, product types

---

### **2. 🍽️ Restaurants & Experiences**
- Restaurant dishes → Remember what you loved
- Coffee shop drinks → Track your favorites
- Menu items → Never forget that amazing pasta

**Tags**: `food`, `restaurant`, venue names, dish types

---

### **3. 📦 Home Inventory**
- Electronics → Track model numbers
- Tools → Know what you have
- Furniture → Remember where you bought it
- Appliances → Track warranties and specs

**Tags**: `electronic`, `functional`, `home`, brands

---

### **4. 👕 Fashion & Wardrobe**
- Clothing items → Track your wardrobe
- Accessories → Remember what you own
- Shoes → Know what you have

**Tags**: `wearable`, `fashion`, colors, materials

---

### **5. 📚 Books, Media & Collections**
- Books → Track your reading list
- Games → Remember what you own
- Collectibles → Catalog your collection

**Tags**: `readable`, `entertainment`, `collection`

---

### **6. 🎁 Gift Ideas & Shopping**
- Gift inspiration → Remember ideas for people
- Shopping wishlist → Track what you want
- Product research → Compare options

**Tags**: `gift`, brands, product types

---

### **7. 🔧 DIY & Projects**
- Materials → Track project supplies
- Tools → Know what you have
- Parts → Find components easily

**Tags**: `functional`, `tool`, `project`, materials

---

### **8. 🌱 Plants & Gardening**
- Plant care → Track your plants
- Seeds → Know what you planted
- Garden products → Remember what works

**Tags**: `plant`, `decorative`, `outdoor`, `living`

---

## 🏷️ How AI Tagging Works

### **Automatic Tag Generation:**

Hela's AI extracts tags from **8 universal categories**:

1. **🎨 Colors**: Visual identification (`blue`, `green`, `multicolor`)
2. **🔨 Materials**: What it's made of (`metal`, `plastic`, `fabric`, `paper`)
3. **🎯 Function**: What it does (`wearable`, `consumable`, `readable`, `decorative`)
4. **🌍 Context**: Where/how it's used (`kitchen`, `bathroom`, `outdoor`, `portable`)
5. **📦 Object Type**: What it is (`mug`, `book`, `plant`, `tool`)
6. **📝 OCR Text**: Brands, labels, text (`CeraVe`, `Blue Bottle`, `Arduino`)
7. **🎨 Attributes**: Notable features (`vintage`, `handmade`, `portable`)
8. **🏷️ Categories**: Broad groupings (`food`, `tech`, `home`, `fashion`)

---

## 🔍 Search Examples

### **"Show me all blue items"**
Search: `blue`
→ Find all blue-colored things

### **"What electronics do I have?"**
Search: `electronic` or `tech`
→ All tech items

### **"Show my plants"**
Search: `plant` or `decorative`
→ All plants and decorations

### **"Find that CeraVe product"**
Search: `CeraVe`
→ All items with that brand (from OCR!)

### **"What's in my kitchen?"**
Search: `kitchen`
→ All kitchen-related items

### **"Show consumables that need restocking"**
Search: `consumable` or `repurchase`
→ Items that run out

### **"What gifts have I saved?"**
Search: `gift`
→ All gift ideas

---

## 📊 Example Outputs

### **☕ Coffee Mug:**
```json
{
  "title": "Blue Ceramic Mug",
  "summary": "A blue ceramic coffee mug with white interior.",
  "category": "general",
  "tags": [
    "blue", "ceramic", "mug", "kitchen", "beverage", 
    "reusable", "storage", "portable"
  ]
}
```

### **📚 Book:**
```json
{
  "title": "Red Paperback Book",
  "summary": "A red paperback book on a wooden table.",
  "category": "general",
  "tags": [
    "red", "paper", "book", "readable", "portable", 
    "education", "entertainment", "indoor"
  ]
}
```

### **🌱 Plant:**
```json
{
  "title": "Green Potted Plant",
  "summary": "A green houseplant in a white ceramic pot.",
  "category": "general",
  "tags": [
    "green", "white", "plant", "decorative", "living",
    "indoor", "ceramic", "natural", "portable"
  ]
}
```

### **🧴 Moisturizer:**
```json
{
  "title": "White CeraVe Moisturizer",
  "summary": "A white bottle of CeraVe moisturizing cream.",
  "category": "general",
  "tags": [
    "white", "plastic", "consumable", "bathroom", 
    "personal-care", "CeraVe", "cream", "bottle", "repurchase"
  ]
}
```

### **🔧 Arduino Kit:**
```json
{
  "title": "Arduino Electronics Kit",
  "summary": "An Arduino Uno development board with components.",
  "category": "electronics",
  "tags": [
    "blue", "electronic", "functional", "tool", 
    "workspace", "Arduino", "tech", "portable", "project"
  ]
}
```

---

## 🤖 Apple Intelligence Integration

Hela is **designed to use Apple Intelligence** (on-device LLM):

### **Current Implementation:**
- ✅ Vision Framework (Apple's built-in image analysis)
- ✅ OCR text extraction (from images)
- ✅ Universal tagging system (works for any object)
- ⚠️ **Mock AI** (hardcoded fallback until Apple Intelligence is available)

### **When Apple Intelligence Launches:**
- 🎯 Replace mock with **real on-device LLM**
- 🔒 **100% private** - no data leaves your device
- 🚀 **Smarter classification** - understands context and nuance
- 💡 **Natural language notes** - AI-generated summaries

---

## 🚀 Future Enhancements

1. **⭐ Ratings**: Add 1-5 star ratings to items
2. **📝 Rich Notes**: Voice notes, longer descriptions
3. **💰 Price Tracking**: Track purchase prices and value
4. **📊 Analytics**: "You bought 15 books this year"
5. **🔔 Smart Reminders**: "Your toothpaste is low, reorder?"
6. **🗺️ Location Tags**: Track where you bought/saw items
7. **🔗 Collections**: Group related items ("Skincare Routine", "Coffee Shops")
8. **🤝 Sharing**: Share collections with friends/family
9. **📈 Inventory Stats**: Value tracking, usage patterns
10. **🔍 Visual Search**: "Find similar items" using AI

---

## 🎨 Design Philosophy

**Hela is built on three principles:**

1. **📸 Photo-First**: Visual memory is powerful
2. **🤖 AI-Powered**: Reduce manual work to zero
3. **🔍 Search-Focused**: Find anything, instantly

**No categories. No folders. Just search.**

---

**Hela: Your entire life, searchable by photo. 📸✨**
