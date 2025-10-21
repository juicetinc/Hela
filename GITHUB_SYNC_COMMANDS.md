# GitHub Sync Commands

## After creating your GitHub repository, run these commands:

### Replace YOUR_USERNAME with your actual GitHub username!

```bash
# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/Hela.git

# Verify remote was added
git remote -v

# Push to GitHub (first time)
git push -u origin main

# Or if you're using 'master' branch:
git branch -M main
git push -u origin main
```

## Future Updates

After making changes to your code:

```bash
# Check what changed
git status

# Add all changes
git add .

# Commit with a message
git commit -m "Your commit message here"

# Push to GitHub
git push
```

## Using Cursor's Git UI

Alternatively, you can use Cursor's built-in Git interface:

1. **View Changes:**
   - Click the Source Control icon (branch icon) in the left sidebar
   - Or press `Cmd+Shift+G` (Mac) / `Ctrl+Shift+G` (Windows)

2. **Commit Changes:**
   - Type your commit message in the text box
   - Click the checkmark ✓ to commit
   - Click the "..." menu → Push

3. **Sync with GitHub:**
   - Click the sync icon (circular arrows) in the bottom bar
   - Or click "..." menu → Push/Pull

## Quick Reference

| Action | Command |
|--------|---------|
| Check status | `git status` |
| Add all files | `git add .` |
| Commit | `git commit -m "message"` |
| Push to GitHub | `git push` |
| Pull from GitHub | `git pull` |
| View branches | `git branch` |
| Create branch | `git checkout -b branch-name` |

## Current Status

✅ Git initialized
✅ Initial commit made (31 files, 4828+ lines)
⏳ Waiting for GitHub remote to be added
⏳ Waiting for first push

---
Created: October 21, 2025

