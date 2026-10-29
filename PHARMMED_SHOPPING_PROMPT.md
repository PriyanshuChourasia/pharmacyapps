# Prompt: Build the `pharmmed` Customer Medicine-Shopping App — UI FIRST, VERY FAST

> Copy everything below the line into your AI coding assistant (run it from the repo root).

---

## Goal

Turn `apps/pharmmed` into a **complete customer app for buying medicines online**, like a modern e-commerce pharmacy app (Amazon-style shopping UX applied to a pharmacy). The user opens the app, sees a rich Home screen full of products, searches or browses, adds to cart, checks out and places an order. Use **local demo data only, no API calls**. No login up front: login is asked for only at "Place order".

Use our own brand name **"PharmMed"** and the teal/green theme from `design_system`. Don't copy any real company's logo, name or assets.

## SPEED IS THE #1 PRIORITY — build the UI very fast

- **Get screens on the emulator as fast as possible.** A working, good-looking screen now beats a perfect one later.
- **Start `flutter run` once and keep it running.** Hot reload (`r`) or hot restart (`R`) after each screen. No full rebuilds.
- **Write each page in one go** with plain Material widgets (`CustomScrollView`, `SliverAppBar`, `GridView`, `ListView`, `Card`, `FilledButton`, `Chip`) and the existing `design_system` widgets. No custom painters, and no new widget abstractions unless two screens need them.
- **Batch your work:** write all the files for a step, then run `flutter analyze` **once**. Don't analyze, explain or re-read after every file.
- **No tests.** Don't write or run tests, and don't add test packages. If an existing test breaks compilation, make the smallest fix or delete that test case.
- **Don't stop for confirmation** between steps, and don't refactor working code.
- **If something takes more than ~10 minutes,** do the simplest version that works, add a `// TODO(polish):` comment, and move on.
- **Use absolute paths from the repo root for every file write:** `/Users/primesysindia/priyanshuprimesys/PersonalFolder/projects/pharmaapp/...`. Feature packages live in `<root>/packages/features/<feature>/`, **never** in `apps/packages/`.
- **A step is done only when it's visible in the running app.** Export the feature from its barrel, add it to `apps/pharmmed/pubspec.yaml`, register it in `apps/pharmmed/lib/app/di/injector.dart`, and route it in `apps/pharmmed/lib/app/router/app_router.dart`.
- After each step: tick `apps/pharmmed/PHASES.md` and post **3 lines max**: what's visible now, how to reach it, and the analyze result.

## Current state (inspected) — what's broken and why the UI shows nothing

- The **Home tab is still a `PlaceholderPage`**, and it's the first screen, so the app looks empty.
- **Catalog routes are broken:** in `app_router.dart` the sub-routes under `/categories` use absolute paths (`RoutePaths.search` = `/categories/search`, and `RoutePaths.productDetailBase + '/:id'`). go_router requires child paths to be **relative** (`search`, `product/:id`), so this asserts or crashes at launch. There is also **no route for a category's product list**.
- **No `CartRepository` is registered in DI**, so tapping "Add" on a product crashes. There's an unused `in_memory_cart_repository.dart` in `feature_cart`.
- **`packages/features/feature_catalog/pubspec.yaml` is missing dependencies** on `core`, `design_system`, `get_it` and `go_router` (220 analyzer issues in that package). The barrel `feature_catalog.dart` also exports itself, so remove that line.
- **Cart, Home, Checkout, Orders and Profile have no code** beyond empty scaffolds.

**What already works and should be reused:**
- `core`: `Result<T>`, `RoutePaths`, the money formatter (int paise → `₹1,234.50`), and the interfaces `AuthSession`, `PaymentGateway`, `KeyValueStore`.
- `shared_models`: `Product`, `Category`, `CartItem`, `Address`, `Order`, `PriceBreakdown`, `Money`, plus the `CartRepository` and `CatalogRepository` interfaces.
- `design_system`: theme, `AppButton`, `EmptyState`, `LoadingView`, `PriceText`, `ProductImage`, `QuantityStepper`, `RxBadge`, `ShimmerBox`, `AnimatedCountText`, `BadgePop`, `StaggeredFadeIn`.
- `feature_catalog`: the demo datasource (~30 medicines), repository, cubits, `CategoriesPage`, `CategoryProductsPage`, `SearchPage`, `ProductDetailPage`, `ProductCard`, `ProductListSkeleton`.
- `feature_auth`: `LoginPage`, `RegistrationPage`.
- Images in `apps/pharmmed/assets/images/`: 3 banners, 8 categories, 5 product shots, 2 illustrations.

## Steps, in order

### Step 1 — Fix the catalog wiring (minutes, not hours)
- Add the missing dependencies to `feature_catalog/pubspec.yaml`, remove the self-export, and get `flutter analyze` in that package down to 0 errors.
- Fix the router: make the sub-routes relative (`search`, `:categoryId`, `product/:id`), add the category products route, and keep `RoutePaths` consistent with the real URLs.
- Register an in-memory `CartRepository` in DI now. Step 3 replaces it.
- **Visible result:** Categories tab → category → product list → product detail, and search works without crashing.

### Step 2 — Home screen, shopping-app style (`feature_home`) — the most important screen
Build it as a `CustomScrollView`, top to bottom:
1. **Header (teal `SliverAppBar`, pinned search):**
   - "Deliver to Rahul – Mumbai 400001 ▾", which opens a bottom sheet with the demo addresses
   - a cart icon with a count badge
   - a big rounded **search bar** ("Search for medicines, health products…") that opens the search route
2. **Quick actions row:** chips/cards for "Upload prescription", "Reorder", "Offers", "Lab tests (coming soon)". Taps that aren't built yet show a snackbar.
3. **Banner carousel:** an auto-advancing `PageView` using the 3 banner images, with overlaid text ("Flat 20% off on medicines", "Free delivery above ₹499", "Vitamins & supplements") and page dots.
4. **"Shop by category":** a 4×2 grid of round category images with labels. Tapping one opens that category's product list.
5. **"Deals of the day":** a horizontal product row with a "% OFF" ribbon and a countdown-style label ("Ends in 05:23:10", a static or ticking `Timer`).
6. **"Popular medicines":** a horizontal row of product cards with Add → `− qty +` stepper.
7. **"Trusted brands":** a row of plain text/initial chips with brand names from the demo data (no real logos).
8. **2-column product grid "Recommended for you"** at the bottom (`SliverGrid`) using the same product card.
9. **Trust strip:** "100% genuine medicines · Licensed pharmacy · Easy returns".

Other requirements:
- Product cards everywhere show: image, name, pack size, MRP crossed out, selling price, a green "xx% off" label, an Rx badge, and an Add button. Out-of-stock items show "Out of stock".
- Shimmer while loading. Data comes through the `CatalogRepository` interface. **`feature_home` must not import `feature_catalog`**, so move `ProductCard` into `design_system` (taking plain values plus callbacks) and use it in both features.
- Replace the Home `PlaceholderPage`.
- **Visible result:** the app opens to a rich, scrollable Home full of products, and every tile navigates.

### Step 3 — Cart (`feature_cart`)
- `PersistedCartRepository` (JSON through `KeyValueStore`, with a `SharedPreferencesKeyValueStore` in `database` or the app) replaces the in-memory one in DI.
- Cart page:
  - line items with image, name, price, qty stepper and "Remove"
  - limit 10 per item, with a snackbar when the limit is hit
  - "Save ₹X on this order" highlight
  - coupon field (`PHARMA10` = 10% off, max ₹100; `FIRST50` = ₹50 off when the order is ≥ ₹300) with an error for an invalid code
  - bill details: Item total (MRP), Discount, Coupon, Delivery (FREE above ₹499, else ₹40), **To pay**, with `AnimatedCountText`
  - Rx banner "Prescription required for N item(s)"
  - sticky bottom bar: "₹X | View bill" + "Proceed to checkout"
- Empty cart: illustration + "Your cart is empty" + "Browse medicines".
- Cart badge on the bottom nav and the Home header, with `BadgePop`.
- **Visible result:** add items anywhere → the badge pops → the cart shows the bill → items survive an app relaunch.

### Step 4 — Checkout + login gate + order success (`feature_checkout`, `feature_auth`)
- `DemoAuthSession` (any non-empty phone/email + password works; the session lasts for the app run), registered in DI. `RoutePaths.login` → `LoginPage`. On success, `context.pop(true)`.
- One checkout page with sections:
  - **Address:** 2 demo addresses as radio cards, plus "Add new address" with a validated form (name, 10-digit phone, 6-digit pincode, address line, city)
  - **Delivery slot:** Today/Tomorrow × Morning/Evening chips
  - **Prescription section** (only if the cart has Rx items): a mock "Upload" that marks it attached and shows a thumbnail placeholder
  - **Payment:** "Cash on Delivery" / "UPI (demo)" (waits 1.5 s, then succeeds) through `DemoPaymentGateway`
  - **Order summary** + sticky "Place order ₹X" button
- Place order:
  - Rx items without a prescription → an error, enforced in the cubit or use case, not only by disabling the button.
  - If the user is a guest, `await context.push(RoutePaths.login)` and continue when it returns.
  - On success, save the order, clear the cart, and go to the success screen.
- Success screen: an animated green check, "Order placed!", order id `PM` + timestamp, "Arriving by <date>", and "View order" / "Continue shopping" buttons.

### Step 5 — Orders + Profile (`feature_orders`, `feature_profile`)
- An `OrdersRepository` interface in `shared_models`, with an in-memory implementation registered in DI and shared by checkout and orders.
- Orders tab:
  - order cards, newest first: id, date, item count, total, and a "Placed" status chip
  - empty state
  - order detail: items, address, slot, payment, bill, and a simple status timeline (Placed → Packed → Shipped → Delivered, with only Placed active)
- Profile tab:
  - **Signed out:** "Hello, Guest" + "Log in / Sign up"
  - **Signed in:** name + phone, then menu tiles: My orders, Saved addresses, Prescriptions, Help & support, About, Log out (unbuilt tiles show a snackbar)
  - keep the debug UI kit tile, debug builds only
- **No `PlaceholderPage` should be left anywhere.** Delete `placeholder_page.dart`.
- Run `flutter build apk --debug` once here.

### Step 6 — Polish (only after everything above works)
- A fade-through `CustomTransitionPage` for pushed routes. Respect `MediaQuery.disableAnimations` in the animation widgets.
- `assets/images/CREDITS.md` listing every image's source URL and license.
- `apps/pharmmed/DEMO_NOTES.md`: demo coupons, demo login, assumptions, and how to swap in a real API (new datasource + DI change).
- Final check. Report each item as pass/fail:
  - the app opens on Home with products
  - search "dolo" → Dolo 650 → add 2 → cart → `PHARMA10` → checkout → address + slot + COD → Place order → login → success → cart empty → the order shows under Orders
  - an Rx cart is blocked without a prescription
  - the cart survives a relaunch
  - `flutter analyze` is clean in the app and every touched package
  - no HTTP calls at runtime, and no `double` for money

## Architecture rules (keep them, but don't over-engineer)

- **State:** `flutter_bloc` Cubits. **DI:** `get_it` only; each feature exposes `registerXModule(GetIt)`. **Routing:** `go_router` `StatefulShellRoute` (Home · Categories · Cart · Orders · Profile), with paths from `RoutePaths` and **relative child paths**. **Models:** plain immutable classes + `equatable`. **Errors:** `Result<T>`.
- **Features never import each other.** They share only `core`, `shared_models` and `design_system`. The app's DI wires implementations. Checkout reaches login **by route path**.
- **Every package must declare in its own `pubspec.yaml` every package it imports.**
- Prices are `int` paise everywhere.
- Don't modify `pharmaadmin` or `pharmabtob`. Add only the packages you use (`flutter_bloc`, `equatable`, `shared_preferences`).
- Don't stop to ask questions. Make a sensible assumption, note it in `DEMO_NOTES.md`, and keep going.
