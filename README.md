# Tubby

Tubby is an iOS-native, local-first companion app for tracking nutrition, exercise, and biometrics with calm, neutral language.

## Current scope

- SwiftUI app shell
- App environment for dependency injection
- Placeholder repository and lookup protocols
- SwiftData model stubs for local persistence
- Swift Testing smoke coverage

## Requirements

- Xcode 16 or later
- iOS 17 deployment target

## Build

Open the project in Xcode and build the app scheme.

If you are using the command line with a full Xcode installation:

```bash
xcodebuild -scheme Tubby -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Test

Run the Swift Testing suite from Xcode or with `xcodebuild`:

```bash
xcodebuild -scheme Tubby -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Notes

- All user data is intended to remain on device.
- No accounts, sync, telemetry, ads, payments, or judgmental goal language are included in this foundation step.
- Networked lookup integrations are intentionally deferred.
