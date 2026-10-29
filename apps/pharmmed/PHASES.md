# pharmmed — Customer Shopping Flow: Phase Checklist

Work one phase at a time. Every phase must leave the app compiling and runnable.
FAST TRACK (see root `PHARMMED_SHOPPING_PROMPT.md`): no new tests, no stop between phases.
A phase is done when `flutter analyze` is clean (pharmmed + touched packages) and
`flutter build apk --debug` succeeds (after Phases 4, 6, 7/8).

## Phase 0 — Read and plan (no code)
- [x] Read every pubspec.yaml, `apps/pharmmed/lib/main.dart`, `feature_auth` pages, `PHARMMED_ARCHITECTURE_PROMPT.md`
- [x] Post plan: dependencies, interface locations, route map, demo data shape, deviations
- [x] Create this checklist (`apps/pharmmed/PHASES.md`)
- [x] Plan confirmed by user (started Phase 1)

## Phase 1 — Foundations + app shell
- [x] `core`: `Result<T>` (`Success`/`Failure`), route path constants, money formatter (paise → `₹1,234.50`), interfaces `AuthSession`, `PaymentGateway`, `KeyValueStore`
- [x] `shared_models`: `Product`, `Category`, `CartItem`, `Address`, `Order`, `PriceBreakdown`, `Money` helpers + `CartRepository` **and `CatalogRepository`** interfaces (deviation: `CartRepository` lives here, not `core`, because it streams `CartItem`; `CatalogRepository` added so Home can show categories/popular items without importing `feature_catalog`)
- [x] `design_system`: theme (teal/green palette, `AppTypography`, `AppSpacing`), `AppButton`, `EmptyState`, `LoadingView`
- [x] App shell: `MaterialApp.router`, go_router `StatefulShellRoute` with 5 placeholder tabs, get_it DI in `lib/app/di/`; `main.dart` no longer shows `AuthFlow`
- [x] Unit tests: money formatter, `Result` (existing; no new tests in fast track)
- [x] Verify: launches on Home placeholder (no login), all 5 tabs switch — widget tests + debug APK build
- [x] **Catalog visible:** Categories tab shows list of 8 categories → tap one → product list with sort/filter → tap product → detail with Hero image. Searching "dolo" finds Dolo 650.

## Phase 2 — Images + design-system widgets + animation widgets
- [x] Download + compress + register images (16 present)
- [ ] Add missing `banners/pills_capsules.jpg` + `categories/baby_care.jpg`, write `CREDITS.md`
- [x] `design_system`: `ProductImage` (fallback), `PriceText`, `QuantityStepper`, `RxBadge`
- [x] `design_system`: `ShimmerBox`, `AnimatedCountText`, `BadgePop`, `StaggeredFadeIn`
- [x] Debug "UI kit" page (reachable from Profile in debug mode only)
- [ ] Verify: UI kit shows real images, fallback placeholder, each animation

## Phase 3 — Demo data + catalog
- [ ] ~30-medicine demo datasource (`Demo…DataSource`, 200–400 ms delay), repository, use cases
- [ ] Category product list with sort (price ↑/↓, name) and filter (OTC/Rx)
- [ ] Debounced (300 ms) search over brand / generic / salt + empty state
- [ ] Product detail: composition, uses, side effects, storage, substitutes, Hero transition, quantity stepper, add/go-to-cart
- [ ] Shimmer loading, out-of-stock state
- [ ] Add-to-cart calls `CartRepository` interface (no stub — real cart built next)
- [ ] Verify: Categories tab lists products; "dolo" finds Dolo 650; "paracetamol" finds several; detail opens with Hero

## Phase 4 — Cart
- [ ] Persisted `CartRepository` (shared_preferences via `KeyValueStore`), registered in DI
- [ ] Cart cubit + cart page: line items, qty stepper, swipe/icon remove (animated), per-line totals
- [ ] Limit 10/item with snackbar
- [ ] Price breakdown (MRP total, discount, delivery fee free > ₹499 else ₹40, payable) with animated totals
- [ ] Coupons `PHARMA10` (10%, max ₹100) and `FIRST50` (₹50 off ≥ ₹300), invalid-code error, check animation
- [ ] Empty cart state with "Browse medicines"; Rx banner "Prescription required for N item(s)"
- [ ] Cart badge with pop animation on nav
- [ ] Verify: badge pops on add, totals + both coupons correct, cart survives app kill/relaunch

## Phase 5 — Home
- [ ] Search bar → catalog search route
- [ ] Auto-scrolling promo banner carousel (page dots, overlaid text)
- [ ] Category grid (8 categories, images)
- [ ] Popular medicines row with Add → stepper morph
- [ ] Staggered entrance animations
- [ ] Verify: Home complete, all entry points navigate

## Phase 6 — Checkout + login gate + order success
- [ ] Address: pick 1 of 2 demo addresses or add (in-memory form: name, 10-digit phone, 6-digit pincode, address line, city)
- [ ] Delivery slot: Today/Tomorrow × Morning/Evening
- [ ] Prescription step (only if cart has Rx): mock attach + thumbnail; enforced by use case returning failure
- [ ] `DemoPaymentGateway` behind `PaymentGateway`: COD / UPI demo (1.5 s then success)
- [ ] Place order → login gate (guest) → back to checkout → success screen (order id `PM`+timestamp, ETA, View orders / Continue shopping), cart cleared
- [ ] `DemoAuthSession` wired; `feature_auth` pages reached by route path
- [ ] Verify: full guest flow works; Rx cart blocked until prescription attached

## Phase 7 — Orders + Profile
- [ ] In-memory orders list (newest first, status "Placed") + order detail (items, address, slot, payment, breakdown)
- [ ] Profile: Guest + "Log in" when signed out; name + "Log out" when signed in
- [ ] Verify: placed order appears under Orders; log in/out updates Profile

## Phase 8 — Polish + final check
- [ ] Consistent page transitions for go_router routes
- [ ] Review every animation against the Animations list; respect `MediaQuery.disableAnimations`
- [ ] Remove or debug-gate the UI kit page
- [ ] Orders repository interface in `shared_models` shared by checkout + orders
- [ ] Write `apps/pharmmed/DEMO_NOTES.md` (assumptions, demo coupons, demo logins, API swap guide)
- [ ] Manual acceptance walkthrough; report pass/fail per item
