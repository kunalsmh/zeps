# Quick Setup Guide

## Initial Setup

1. **Install Dependencies**
   ```bash
   pod install
   ```

2. **Configure Supabase**
   
   The app needs your Supabase credentials. You have two options:

   **Option A: Environment Variables (Recommended)**
   ```bash
   export SUPABASE_URL="https://your-project.supabase.co"
   export SUPABASE_ANON_KEY="your-anon-key-here"
   ```

   **Option B: Edit SupabaseConfig.swift**
   
   Currently, the app has hardcoded values in `app/Managers/SupabaseConfig.swift` as a fallback. For production, you should:
   - Use environment variables, OR
   - Create a local config file (see README.md for details)

3. **Configure Google Sign-In**
   - Add `GoogleService-Info.plist` to your Xcode project
   - This file is gitignored and won't be committed

4. **Set Up Database**
   - Run `supabase_schema.sql` in your Supabase SQL Editor

5. **Open Workspace**
   ```bash
   open app.xcworkspace
   ```

## Security Checklist

Before committing to GitHub:

- ✅ `.gitignore` is in place
- ✅ API keys are not hardcoded (or are in gitignored files)
- ✅ `GoogleService-Info.plist` is gitignored
- ✅ User-specific Xcode files are gitignored
- ✅ Build artifacts are gitignored

## Files That Should NOT Be Committed

- `app/Managers/SupabaseConfig.local.swift` (if you create it)
- `GoogleService-Info.plist`
- `xcuserdata/` directories
- `Pods/` directory (if you choose to ignore it)
- `*.xcworkspace` (except `contents.xcworkspacedata`)

All of these are already in `.gitignore`.

