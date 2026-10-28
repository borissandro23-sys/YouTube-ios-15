# RetroTube

A small SwiftUI + WebKit client that opens the mobile YouTube website and targets iOS 15.0 or later.

> RetroTube is an independent web client, not the official YouTube app and not a modification of its binary. The website, playback, sign-in, and other features remain controlled by YouTube and may change.

## Features

- Mobile YouTube homepage in `WKWebView`
- Back, forward, home, reload/stop controls
- Loading progress indicator
- iPhone and iPad target
- Xcode project generated with XcodeGen
- GitHub Actions workflow that builds an **unsigned IPA artifact**

## Project layout

- `Sources/RetroTubeApp.swift` — SwiftUI app and WKWebView wrapper
- `project.yml` — XcodeGen project configuration (bundle ID and iOS deployment target)
- `.github/workflows/build.yml` — CI build and IPA packaging

## Build locally

Requirements: macOS, Xcode with iOS SDK, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
xcodebuild \
  -project RetroTube.xcodeproj \
  -scheme RetroTube \
  -sdk iphoneos \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  build
```

To package the unsigned app after a successful build:

```sh
mkdir -p ipa/Payload
cp -R build/Build/Products/Release-iphoneos/RetroTube.app ipa/Payload/RetroTube.app
(cd ipa && zip -qry ../RetroTube-unsigned.ipa Payload)
```

## GitHub Actions

A push to `main` or a manual run from **Actions → Build RetroTube IPA → Run workflow** builds the app. Download `RetroTube-unsigned-IPA` from the workflow run's Artifacts section.

The artifact is unsigned. It is not directly installable on a normal iPhone/iPad until it is signed using an appropriate Apple development signing setup. This workflow does not publish to the App Store.

## Important limitations

- This is a web wrapper; it does not restore or patch the official YouTube 19.x app.
- YouTube may change its website, playback requirements, authentication flow, or policies at any time.
- App Store review may reject a thin website wrapper or an app that does not provide sufficient functionality beyond the website.
- The first CI run is the real compile check; if it fails, inspect the workflow logs and fix the reported issue.
