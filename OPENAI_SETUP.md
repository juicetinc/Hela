# 🤖 AI Classification Setup

Hela uses **Apple Intelligence** (iOS 18+) for on-device AI classification! ChatGPT is available as an optional fallback for devices without Apple Intelligence.

## 🍎 Apple Intelligence (Primary - FREE!)

**No setup required!** If you're on iOS 18+ with a compatible device, Hela automatically uses Apple Intelligence:
- ✅ **On-device** - works offline, ultra-fast
- ✅ **Private** - data never leaves your device
- ✅ **Free** - no API costs
- ✅ **Optimized** - built for Apple Silicon

**Compatible Devices:**
- iPhone 15 Pro, 15 Pro Max, 16, 16 Pro
- iPad with M1 or later
- Mac with M1 or later

---

## 🤖 ChatGPT Fallback (Optional)

For older devices or if you prefer ChatGPT, you can optionally configure an OpenAI API key:

---

## ✅ **Step 1: Get Your OpenAI API Key**

1. Go to [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Sign in or create an account
3. Click **"Create new secret key"**
4. Copy the API key (starts with `sk-...`)

⚠️ **Important:** Keep this key secret! Never share it or commit it to git.

---

## ✅ **Step 2: Configure Xcode**

### **Option A: Environment Variable (Recommended)**

1. In Xcode, go to **Product → Scheme → Edit Scheme...**
2. Select **Run** on the left
3. Go to the **Arguments** tab
4. Under **Environment Variables**, click **+**
5. Add:
   - **Name:** `OPENAI_API_KEY`
   - **Value:** `sk-your-api-key-here`
6. Click **Close**

### **Option B: Config File (Alternative)**

1. Open `Config.xcconfig` in Xcode
2. Add your API key:
   ```
   OPENAI_API_KEY = sk-your-api-key-here
   ```
3. In Xcode, go to your project settings
4. Select your target → **Info** tab
5. Click **+** under **Configurations**
6. Set `Config.xcconfig` for Debug and Release

---

## ✅ **Step 3: Test It**

1. **Build and run** the app
2. **Take a photo** or select one from your library
3. Check the Xcode console:
   - ✅ `🤖 Using ChatGPT API for classification...`
   - ✅ `ChatGPT classification successful`

---

## 💰 **Pricing**

Using the `gpt-4o-mini` model:
- **Cost:** ~$0.0001 per image analysis
- **Example:** 10,000 photos = ~$1.00

Very affordable for personal use!

---

## 🔄 **Fallback Chain**

Hela tries classification methods in this order:
1. **🍎 Apple Intelligence** (iOS 18+, on-device, free)
2. **🤖 ChatGPT API** (if API key configured)
3. **📝 Mock Classification** (uses Vision data, always works)

This ensures you always get intelligent results, even offline or on older devices!

---

## 🔒 **Security**

- ✅ API key is stored locally on your device only
- ✅ Never committed to git (protected by `.gitignore`)
- ✅ Only you have access to your key
- ✅ Vision data is sent over HTTPS

---

## ❓ **Troubleshooting**

### "No OpenAI API key found"
- Check that you added the environment variable or config file
- Restart Xcode after making changes

### "OpenAI API error: Status 401"
- Your API key is invalid or expired
- Generate a new key from OpenAI dashboard

### "OpenAI API error: Status 429"
- You've exceeded your rate limit
- Add credits to your OpenAI account or wait

---

**Need help?** Check the [OpenAI API docs](https://platform.openai.com/docs)

