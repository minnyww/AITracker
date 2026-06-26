# AI Usage Tracker

macOS menu bar app to track AI coding assistant usage.

## Features

- Track **Z.ai** and **Osiris** API usage
- Menu bar widget with stacked usage bars
- Popover with detailed stats
- Auto-refresh every 5 minutes
- Secure API key storage

## Supported Services

| Service | Data Source | Status |
|---------|-------------|--------|
| Z.ai | API (user key) | ✅ |
| Osiris | API (user key) | ✅ |
| OpenCode | Local SQLite | ❌ (requires native app) |

## Setup

1. Open `AITracker.xcodeproj` in Xcode
2. Build and run (⌘R)
3. Click the menu bar icon
4. Go to Settings (⚙️)
5. Enter your API keys:
   - **Z.ai**: Get from z.ai
   - **Osiris**: Get from osiris-code.com/app/dashboard

## API Keys

- **Z.ai**: `your-zai-api-key`
- **Osiris**: `sk-osiris-...` (format: `sk-osiris-{32 hex chars}`)

## Build

```bash
# Using Xcode
open AITracker.xcodeproj

# Or using command line
xcodebuild -project AITracker.xcodeproj -scheme AITracker -configuration Release
```

## Notes

- API keys are stored in UserDefaults (consider Keychain for production)
- Auto-refresh interval: 5 minutes (configurable in Settings)
- Z.ai API endpoint may need adjustment based on their actual API
- Osiris dashboard API may need adjustment based on their actual API
# AITracker
