# Pharmaapp

A Flutter monorepo for a pharmacy platform, containing multiple apps and shared packages.

## Structure

```
apps/
  pharmaadmin/    # Admin app
  pharmabtob/     # B2B app
  pharmmed/       # Consumer/medical app

packages/
  authentication/  # Auth logic shared across apps
  core/            # Core utilities and shared functionality
  database/        # Data persistence layer
  design_system/   # Shared UI components and theming
  network/         # Networking layer
  shared_models/   # Shared data models
```

## Getting Started

Each app under `apps/` is an independent Flutter project that depends on the local packages under `packages/`.

To run an app, `cd` into it and use the standard Flutter workflow:

```bash
cd apps/pharmaadmin
flutter pub get
flutter run
```

Repeat for `pharmabtob` and `pharmmed` as needed.

## Packages

The `packages/` directory holds shared Dart/Flutter packages consumed by the apps via local path dependencies. Run `flutter pub get` inside a package directory after making changes so dependent apps pick them up.
