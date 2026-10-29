# Prompt: Modular Architecture for `pharmmed`

> Copy everything below the line into your AI coding assistant (run it from the repo root).

---

## Role

You are a senior Flutter architect. Your task is to design and scaffold a **modular, feature-first, clean architecture** for the `pharmmed` mobile app (the consumer/patient-facing pharmacy app) inside this Flutter monorepo.

## Current state of the repo

```
pharmaapp/
  apps/
    pharmaadmin/     # Admin app        (do NOT modify in this task)
    pharmabtob/      # B2B app          (do NOT modify in this task)
    pharmmed/        # Consumer app     ← TARGET (currently the default counter app)
  packages/
    authentication/  # empty scaffold
    core/            # empty scaffold
    database/        # empty scaffold
    design_system/   # empty scaffold
    network/         # empty scaffold
    shared_models/   # empty scaffold
  tooling/           # empty
```

- Dart SDK `^3.10.7`, `flutter_lints ^6.0.0`.
- Every package is still the default `flutter create --template=package` output.
- `pharmmed` does not yet depend on any local package.

Before writing code, read the existing `pubspec.yaml` files and `lib/` contents so you build on what is there rather than assuming.

## Goals

1. `pharmmed` is a thin **shell app**: bootstrapping, environment config, DI wiring, routing, and composition of feature modules — nothing else.
2. Each business capability lives in its **own feature package**, independently buildable and testable.
3. Shared packages under `packages/` are **reusable by all three apps** (`pharmmed`, `pharmaadmin`, `pharmabtob`) and contain no `pharmmed`-specific logic.
4. A strict, one-directional **dependency graph** that can be enforced by tooling.

## Target structure

```
apps/pharmmed/
  lib/
    main_dev.dart / main_staging.dart / main_prod.dart   # flavor entry points
    bootstrap.dart                                      # error zones, DI init, runApp
    app/
      app.dart                                          # MaterialApp.router, theme, l10n
      router/                                           # root router composing feature routes
      di/                                               # composition root (registers all modules)
      config/                                           # flavor/env config (base URLs, keys)

packages/
  core/             # Result/Either, failures & exceptions, logger, extensions, constants,
                    # base UseCase, env abstraction. Pure Dart where possible. No UI.
  network/          # HTTP client (Dio), interceptors (auth token, refresh, logging, retry),
                    # error → Failure mapping, connectivity checks.
  database/         # Local persistence abstractions + impl (secure storage for tokens,
                    # key-value cache, local DB for cart/offline data).
  authentication/   # Auth domain + data: login (OTP/phone & email), token lifecycle,
                    # session state stream. Exposes an AuthRepository interface.
  shared_models/    # DTOs/entities shared across apps (User, Address, Product, Order, Money…),
                    # JSON serialization, value objects.
  design_system/    # Theme, color/typography/spacing tokens, reusable widgets
                    # (buttons, inputs, cards, empty/error/loading states), icons, assets.

  features/         # NEW — pharmmed feature modules (one package each)
    feature_onboarding/      # splash, intro, permissions
    feature_auth/            # login/OTP/signup UI on top of `authentication`
    feature_home/            # home feed, banners, categories
    feature_catalog/         # medicine search, product listing & detail, substitutes
    feature_prescription/    # upload/scan prescription, prescription history
    feature_cart/            # cart, coupons, price breakdown
    feature_checkout/        # address selection, delivery slot, payment
    feature_orders/          # order list, order detail, tracking, reorder
    feature_profile/         # profile, addresses, family members, settings
    feature_notifications/   # push + in-app notifications, refill reminders

tooling/            # melos config helpers, scripts, code generators, lint rules
```

### Inside every feature package

```
feature_x/
  lib/
    feature_x.dart              # PUBLIC API ONLY: route definitions, module registration,
                                # and any contracts other features may use
    src/
      domain/
        entities/
        repositories/           # abstract interfaces
        usecases/
      data/
        datasources/            # remote (network) + local (database)
        models/                 # DTOs + mappers to domain entities
        repositories/           # implementations
      presentation/
        state/                  # controllers / blocs / notifiers
        pages/
        widgets/
      di/                       # registers this feature's dependencies
  test/                         # mirrors lib/src
  pubspec.yaml
```

Everything under `src/` is private; other packages may import only `feature_x.dart`.

## Dependency rules (must be enforced)

```
apps/pharmmed  →  features/*  →  authentication, network, database, shared_models, design_system  →  core
```

- `core` depends on nothing internal.
- Shared packages may depend on `core` (and `shared_models` where needed) but **never** on a feature or an app.
- Features **never import other features directly**. Cross-feature navigation goes through route names/paths defined in a shared contract; cross-feature data goes through interfaces declared in `core`/`shared_models` and wired in the app's composition root.
- `domain` layers contain no Flutter, Dio, or storage imports.
- `presentation` never talks to `data` directly — only through use cases/repositories.

Add a check that fails CI when these rules are broken (e.g. a script in `tooling/` that parses imports, or a lint rule).

## Technology defaults

Use these unless you find a strong reason not to; if you deviate, explain why.

| Concern | Default |
|---|---|
| Monorepo management | **Melos** (or Dart pub workspaces) — `bootstrap`, `analyze`, `test`, `format`, `build_runner` scripts |
| State management | **flutter_bloc** (Cubit for simple screens, Bloc for event-heavy flows) |
| Dependency injection | **get_it** + **injectable**, one module per package |
| Routing | **go_router**, each feature exports its own `List<RouteBase>`; auth-guard redirect in app |
| Networking | **dio** + **retrofit** |
| Serialization / immutability | **freezed** + **json_serializable** |
| Local storage | **flutter_secure_storage** (tokens), **shared_preferences** (flags), **drift** or **isar** (offline cart/catalog cache) |
| Error handling | `Result<T>` / `Either<Failure, T>` from `core`; no raw exceptions crossing layer boundaries |
| Localization | `flutter_localizations` + ARB files (English + Hindi to start) |
| Flavors | `dev`, `staging`, `prod` for Android & iOS |
| Testing | `flutter_test`, `bloc_test`, `mocktail`; golden tests for `design_system` |
| Lints | `very_good_analysis` or a shared `analysis_options.yaml` in `tooling/` used by every package |

## Pharmacy-specific requirements to account for

- **Prescription handling**: camera/gallery upload, image compression, multi-page prescriptions, verification status flow (pending → approved → rejected).
- **Rx vs OTC products**: Rx items require a valid prescription before checkout — model this as a domain rule, not a UI check.
- **Medicine search**: debounced search, search by brand/generic/salt, substitute suggestions.
- **Refill reminders**: local notifications scheduled from order history.
- **Privacy**: health data and prescriptions are sensitive — tokens and PII in secure storage only, no PII in logs, certificate pinning hook in `network`.
- **Offline tolerance**: cart and recently viewed items persist locally and sync when online.
- **Payments**: abstract `PaymentGateway` interface in `core`/`checkout` so the provider (Razorpay, etc.) is swappable.

## Deliverables

Work in this order, and stop after each phase to summarize what changed:

1. **Architecture doc** — `apps/pharmmed/ARCHITECTURE.md` with the module diagram, dependency rules, layer responsibilities, and how to add a new feature.
2. **Monorepo tooling** — Melos/workspace config at root, shared `analysis_options.yaml`, scripts, and the dependency-rule checker.
3. **Shared packages** — implement the foundational code in `core`, `network`, `database`, `authentication`, `shared_models`, `design_system` (real, minimal implementations; no placeholder `Calculator` classes).
4. **App shell** — flavors, `bootstrap.dart`, DI composition root, root router with auth guard, theme from `design_system`.
5. **Reference feature** — fully implement `feature_catalog` end to end (domain → data → presentation → tests) as the template every other feature follows.
6. **Remaining features** — scaffold the other feature packages with the folder structure, a public API file, a registered route, and a placeholder page, so the app runs and navigates between them.
7. **Feature generator** — a script or `mason` brick in `tooling/` that creates a new feature package with the standard structure.

## Acceptance criteria

- `melos bootstrap` (or `flutter pub get` at the workspace root) succeeds.
- `melos run analyze` reports zero issues across all packages.
- `melos run test` passes; `feature_catalog` has unit tests for use cases/repositories and bloc tests for its state.
- `flutter run --flavor dev -t lib/main_dev.dart` launches `pharmmed` and navigates splash → login → home → catalog → product detail.
- The dependency-rule check passes, and fails if a feature imports another feature.
- `pharmaadmin` and `pharmabtob` still build (unchanged).

## Constraints

- Do not modify `pharmaadmin` or `pharmabtob` beyond what is needed for them to keep building.
- Do not add dependencies that aren't used.
- Keep generated files (`*.g.dart`, `*.freezed.dart`) out of manual edits; add `build_runner` scripts.
- Prefer small, composable classes; avoid god-objects and global singletons outside the DI container.
- If a requirement is ambiguous (backend API shape, payment provider, auth method), state the assumption you made in `ARCHITECTURE.md` rather than blocking.
