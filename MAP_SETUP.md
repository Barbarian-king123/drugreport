Android
-------
1. Obtain a Google Maps API key from Google Cloud Console and enable Maps SDK for Android.
2. Open `android/app/src/main/AndroidManifest.xml` and replace the placeholder `YOUR_API_KEY` in the `com.google.android.geo.API_KEY` meta-data with your key.
3. Ensure `minSdkVersion` in `android/app/build.gradle.kts` meets the `google_maps_flutter` plugin requirements.

iOS
---
1. Obtain a Google Maps API key and enable Maps SDK for iOS.
2. Add the key in `AppDelegate.swift` (or `AppDelegate.m`) by calling `GMSServices.provideAPIKey("YOUR_API_KEY")` inside `application(_:didFinishLaunchingWithOptions:)`.
3. Add location permission descriptions to `ios/Runner/Info.plist`:
   - `NSLocationWhenInUseUsageDescription` with a user-facing string explaining why the app needs location.
4. If using CocoaPods, run `pod install` in `ios/` after updating dependencies.

Testing
-------
Run:

```bash
flutter pub get
flutter run
```

Notes
-----
- Do not commit API keys to version control. Use CI secrets or native config files excluded from source control.
- On Android, the meta-data entry in `AndroidManifest.xml` is sufficient for many setups. On iOS, you must explicitly provide the key via `GMSServices.provideAPIKey` in the native AppDelegate.
