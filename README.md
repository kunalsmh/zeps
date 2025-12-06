![Zeps Screenshot](https://github.com/kunalsmh/zeps/blob/main/ts.png)

Zeps is an app for Indian high schoolers, giving you everything you need to ace your classes. It also helps you build a strong college-ready profile and shows which universities you’re most likely to get into based on your profile.

## Self building

1. Clone the repository:
```bash
git clone <repository-url>
cd app
```

2. Install CocoaPods dependencies:
```bash
pod install
```

3. Open the workspace (not the project):
```bash
open app.xcworkspace
```

### Configuration

#### Supabase Configuration

The app uses Supabase as the backend. To configure your API keys:

**Option 1: Environment Variables (Recommended for CI/CD)**
```bash
export SUPABASE_URL="your_supabase_url"
export SUPABASE_ANON_KEY="your_supabase_anon_key"
```

**Option 2: Local Config File (Recommended for Development)**
1. Copy the template file:
```bash
cp app/Managers/SupabaseConfig.local.swift.example app/Managers/SupabaseConfig.local.swift
```

2. Edit `app/Managers/SupabaseConfig.local.swift` and add your Supabase credentials.

**Note:** `SupabaseConfig.local.swift` is gitignored and will not be committed to the repository.

#### Google Sign-In Configuration

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Sign-In API
3. Create OAuth 2.0 credentials
4. Add your bundle identifier
5. Download `GoogleService-Info.plist` and add it to your project
6. **Important:** `GoogleService-Info.plist` should be gitignored (already included in `.gitignore`)

### Database Setup

Run the SQL schema file to set up your Supabase database:

```bash
# In Supabase SQL Editor, run:
supabase_schema.sql
```

This will create:
- `subjects` table
- `users` table
- Row Level Security policies
- RPC functions

## Project Structure

```
app/
├── app/                    # Main app source code
│   ├── Managers/          # Business logic managers
│   ├── Models/            # Data models
│   ├── Views/             # SwiftUI views
│   └── Widget/            # Widget extensions
├── supabase_schema.sql    # Database schema
└── Podfile                # CocoaPods dependencies
```

## Security

- API keys are stored in environment variables or local config files (gitignored)
- Never commit sensitive credentials to the repository
- The `.gitignore` file excludes:
  - `SupabaseConfig.local.swift`
  - `GoogleService-Info.plist`
  - User-specific Xcode files
  - Build artifacts

## Development

### Running the App

1. Open `app.xcworkspace` in Xcode
2. Select your target device/simulator
3. Build and run (⌘R)

### Adding New Dependencies

If you need to add new CocoaPods:

1. Edit `Podfile`
2. Run `pod install`
3. Open `app.xcworkspace` (not `app.xcodeproj`)

## License

[Add your license here]

## Contributing

[Add contributing guidelines here]

