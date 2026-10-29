# Prompt: Create Folder Layout for `pharmmed`

> Copy everything below the line into your AI coding assistant (run it from the repo root).

---

## Task

Create the **folder layout only** for a modular architecture of the `pharmmed` Flutter app in this monorepo. Do **not** write any business logic, widgets, state management, DI, or routing code. Only create directories, feature packages, and empty placeholder files.

## Current repo

```
pharmaapp/
  apps/pharmmed/           # default Flutter counter app (target)
  apps/pharmaadmin/        # do NOT touch
  apps/pharmabtob/         # do NOT touch
  packages/                # core, network, database, authentication,
                           # shared_models, design_system (empty scaffolds)
  tooling/                 # empty
```

Read the existing folders first so you don't overwrite anything.

## Create this layout

```
apps/pharmmed/lib/
  app/
    router/
    di/
    config/

packages/
  core/lib/src/
  network/lib/src/
  database/lib/src/
  authentication/lib/src/
  shared_models/lib/src/
  design_system/lib/src/

  features/
    feature_onboarding/
    feature_auth/
    feature_home/
    feature_catalog/
    feature_prescription/
    feature_cart/
    feature_checkout/
    feature_orders/
    feature_profile/
    feature_notifications/

tooling/scripts/
```

### Every feature package must look like this

```
feature_x/
  lib/
    feature_x.dart            # public API file; contains only a doc comment + `library;`
    src/
      domain/
        entities/
        repositories/
        usecases/
      data/
        datasources/
        models/
        repositories/
      presentation/
        state/
        pages/
        widgets/
      di/
  test/
    src/
  pubspec.yaml
```

## Rules

1. Create each feature package with `flutter create --template=package --project-name <name> packages/features/<name>` so it has a valid `pubspec.yaml`.
2. Replace the generated `Calculator` boilerplate in `lib/<name>.dart` with:
   ```dart
   /// Public API for <name>. Export only what other packages may use.
   library;
   ```
3. Delete the generated `test/<name>_test.dart`.
4. Put a `.gitkeep` file in every empty directory so git tracks it.
5. Skip any package or folder that already exists; never overwrite existing files.
6. Do not modify `pharmaadmin`, `pharmabtob`, or any `pubspec.yaml` dependencies.
7. Do not add any packages or dependencies.

## Done when

- All folders above exist, with `.gitkeep` in the empty ones.
- `flutter analyze` passes inside each new feature package.
- You print the final tree (`find packages/features apps/pharmmed/lib tooling -type d | sort`) and list everything you created.
