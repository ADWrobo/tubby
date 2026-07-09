# Tubby

Tubby is an iOS-native, local-first companion app for tracking nutrition, exercise, and biometrics with calm, neutral language.

## Current scope

- SwiftUI app shell
- App environment for dependency injection
- Expressive domain models for food, exercise, and biometrics
- Async repository contracts plus in-memory and SwiftData-backed implementations
- Manual food logging UI backed by local repositories
- Placeholder lookup providers for deferred network integrations
- Swift Testing coverage for domain calculations and repository behavior

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
- SwiftData local persistence stores user logs on device and backs the live app environment.
