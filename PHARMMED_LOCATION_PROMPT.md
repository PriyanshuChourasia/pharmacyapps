# Prompt: Location Setup Screen After Login / Skip (`pharmmed`)

> Copy everything below the line into your AI coding assistant (run it from the repo root).

---

## Goal

In `apps/pharmmed`, after the user **logs in with phone OTP**, **continues with Google**, or **taps "Skip"** on the login screen, open a new **Location Setup screen** instead of going straight to Home.

The screen looks like this:

- **Center:** a map-style design (illustration), with an animated location pin in the middle.
- **Bottom sheet/card** with:
  - Title: "Where should we deliver?" and a one-line subtitle.
  - Primary button: **"Enable location"**
  - Secondary button: **"Enter location manually"**

When the user taps **Enable location**, the app must check **both** of these, in this order, before it reads the location:
1. **Is the app's location permission granted?**
2. **Is the device's Location service (GPS) turned ON?**

Handle every case (listed below), then save the location and go Home.

## Rules

- **Absolute paths only** for every file write: `/Users/primesysindia/priyanshuprimesys/PersonalFolder/projects/pharmaapp/...`. Packages live in `<root>/packages/...`, never in `apps/packages/`.
- Use `design_system` widgets and tokens (`AppButton`, `AppButtonVariant`, `AppColors`, `AppSpacing`, `showAppSnackBar`). Use the teal theme. Don't hard-code new colors unless the theme has nothing that fits.
- **No Google Maps SDK and no API keys.** Draw the map yourself with `CustomPainter` (light road grid, a few blocks/parks, a soft radial pulse behind the pin). Respect `MediaQuery.disableAnimationsOf(context)`.
- Don't refactor screens that already work. Don't ask questions. If you have to assume something, write it in `apps/pharmmed/DEMO_NOTES.md` and keep going.
- When you finish, run `flutter analyze` once in `apps/pharmmed` and fix every issue.

## What exists today (I checked these, so reuse them)

- `apps/pharmmed/lib/app/widgets/login_screen.dart`: `_finish({signedIn, greeting})` is the only exit. When the screen can pop, it does `context.pop(signedIn)` (pushed from checkout/profile). Otherwise it does `context.go(RoutePaths.home)`. Phone OTP (`_verify`), Google (`_continueWithGoogle`) and Skip (`_Header.onClose → _finish(signedIn: false)`) all go through it.
- `apps/pharmmed/lib/app/widgets/splash_screen.dart` → `_goNext()` goes to `home` if the user is logged in, otherwise to `login`.
- `apps/pharmmed/lib/app/services/location_permission_service.dart`: `LocationPermissionService` wraps `permission_handler` (`status()`, `request()`, `openSettings()`, `forceStatusForTest`) and returns a `LocationPermissionStatus` enum (`granted, limited, denied, permanentlyDenied, unknown`).
- `apps/pharmmed/lib/app/widgets/location_permission_gate.dart` plus `lib/app/app.dart`: right now **the whole app is wrapped in `LocationPermissionGate`**, which asks for location on the very first launch, before the splash. **That conflicts with this flow.**
- `packages/core`: `RoutePaths` (add new paths here) and `KeyValueStore` (`read/write/delete`), registered in GetIt through `apps/pharmmed/lib/app/di/injector.dart`.
- `packages/features/feature_checkout/.../add_address_page.dart`: `AddAddressPage`, already routed at `RoutePaths.addAddress`.
- Android manifest already has `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`. iOS `Info.plist` already has `NSLocationWhenInUseUsageDescription`.
- `permission_handler: ^13.0.2` with an override `permission_handler_android: 13.0.1`. **Keep this override** because AGP is 8.11.

## Step 1: Remove the launch-time gate

- In `lib/app/app.dart`, stop wrapping `MaterialApp.router` in `LocationPermissionGate`. Leave `location_permission_gate.dart` in the repo, unused, or delete it if nothing else imports it.
- Register `LocationPermissionService` as a lazy singleton in `injector.dart`.

## Step 2: Platform setup

- **iOS (required, or permission always reads as denied):** in `apps/pharmmed/ios/Podfile`, inside `post_install` → `target.build_configurations.each`, add:
  ```ruby
  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'PERMISSION_LOCATION=1']
  ```
  (If that block already exists, append `'PERMISSION_LOCATION=1'` to it.)
- Add `geolocator` (latest version that's compatible with AGP 8.11; if the newest one breaks the Android build, pin an older one and note it in `DEMO_NOTES.md`) to read the position and open the device's Location settings. Add `geocoding` to turn coordinates into a readable address. If geocoding fails, fall back to `"Current location (lat, lng)"`.

## Step 3: Extend the service with a device-service check

Add these to `LocationPermissionService` (keep the existing API working):

```dart
Future<bool> isServiceEnabled();          // Permission.location.serviceStatus.isEnabled (or Geolocator.isLocationServiceEnabled)
Future<bool> openLocationSettings();      // Geolocator.openLocationSettings()
Future<LocationResult> currentLocation(); // Geolocator.getCurrentPosition(timeLimit: 10s) + reverse geocode
```

Put a small `LocationResult` model (lat, lng, `label`, `city?`, `pincode?`) in `apps/pharmmed/lib/app/services/`.

## Step 4: The "Enable location" flow (must do exactly this)

When the user taps **Enable location**, show a loading state on the button and run:

1. `status()` → **check the permission first.**
   - `granted` / `limited` → go to step 2.
   - `denied` → call `request()`.
     - Granted now → step 2.
     - Still denied → snackbar: "Location permission is needed to detect your address". Stay on the screen. Both buttons keep working.
   - `permanentlyDenied` → bottom sheet: "Location permission is off. Open Settings → Permissions → Location and allow it." with **"Open settings"** (`openSettings()`) and **"Enter manually"** buttons.
   - `unknown` → snackbar asking the user to enter the location manually.
2. `isServiceEnabled()` → **check that the device's Location service is ON.**
   - ON → step 3.
   - OFF → bottom sheet: "Your device location is turned off. Turn it on to detect your address." with **"Turn on location"** (`openLocationSettings()`) and **"Enter manually"** buttons.
3. `currentLocation()` → show "Detecting your location…" over the map. Move the pin and pulse it.
   - Success → show the detected address in a confirm card ("Deliver to: <label>") with **"Confirm & continue"** and **"Change"** (Change opens manual entry).
   - Timeout or error → snackbar plus the option to enter manually.

**Re-check when the user comes back from Settings:** use `WidgetsBindingObserver.didChangeAppLifecycleState`. When the state is `resumed` and the user had been sent to app settings or location settings, run the flow again automatically from the step they left. Don't make them tap Enable again.

## Step 5: "Enter location manually"

- Push `RoutePaths.addAddress` (`AddAddressPage`) if it can be used standalone and returns the saved `Address`. If it can't, build a lightweight `ManualLocationPage` in `lib/app/widgets/`: a pincode field (6 digits), area/street, city, and an optional landmark, plus a "Save & continue" button with validation.
- When it saves, go to the same "confirm & go Home" step.

## Step 6: Save the location and route

- Save the chosen location to `KeyValueStore` under `user_location` as JSON (`lat`, `lng`, `label`, `source: gps|manual`).
- When confirmed: `context.go(RoutePaths.home)`.
- Add `RoutePaths.locationSetup = '/location-setup'` in `core`. Register it in `app_router.dart` with `_top(...)` or a plain `GoRoute`, and **no back button** to the login screen.
- **Login screen change:** in `_finish`, keep the `canPop` branch exactly as it is (checkout/profile still get `pop(true/false)`). In the non-pop branch (from the splash), go to `RoutePaths.locationSetup` **if no `user_location` is saved**, otherwise go to `home`. This covers OTP, Google and Skip.
- **Splash change:** if the user is logged in **and** `user_location` is missing, go to `locationSetup` instead of `home`.
- Optional (nice to have): show the saved `label` in the Home app bar ("Deliver to ▾"). Tapping it reopens `locationSetup`.

## Step 7: Verify (state each result in your final message)

Check each case on a real Android device or emulator (and on iOS if you can):

| # | Case | Expected |
|---|------|----------|
| 1 | OTP login → first time | Location Setup screen opens |
| 2 | Google login → first time | Location Setup screen opens |
| 3 | Skip | Location Setup screen opens |
| 4 | Enable → permission dialog → Allow, GPS on | Address detected → confirm → Home |
| 5 | Enable → Deny | Snackbar, stays on screen |
| 6 | Enable → "Don't ask again" / permanently denied | "Open settings" sheet. Grant in Settings → return → flow continues automatically |
| 7 | Permission granted, device GPS **off** | "Turn on location" sheet → opens Location settings → turn on → return → flow continues automatically |
| 8 | Enter manually → fill form → save | Home, with the label saved |
| 9 | Kill and reopen the app after a location is saved | Splash → Home (no Location Setup) |
| 10 | Login pushed from checkout | Still pops back to checkout, does **not** open Location Setup |

Finish with `flutter analyze` showing 0 issues, and give a list of the files you changed.
