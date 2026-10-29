# Prompt: Build ALL Remaining Screens of `pharmmed` (Customer Medicine-Shopping App)

> Copy everything below the line into your AI coding assistant (run it from the repo root).

---

## Goal

`apps/pharmmed` is a customer app for buying medicines online, with a shopping UX like a modern e-commerce pharmacy (Amazon-style browsing, rich home, cart with bill details, quick checkout). Brand name: **"PharmMed"**, with the teal/green theme from `design_system`. Don't copy any real company's name, logo or assets.

Right now **only the Categories tab works**. Home, Cart, Orders and Profile are still `PlaceholderPage`s, and Checkout, Login gate, Order success, Orders and Profile have no code at all. **Build every remaining screen in this prompt, fully, and wire each one so it's visible in the running app.**

Use local demo data only, no API calls. No login up front: login is asked for only when the user taps "Place order".

## Speed rules — build the UI very fast

- **Start `flutter run` in `apps/pharmmed` once and keep it running.** Hot reload or restart after each screen.
- **Write each page in one go** with plain Material widgets (`CustomScrollView`, `SliverAppBar`, `SliverGrid`, `ListView`, `Card`, `ListTile`, `FilledButton`, `ChoiceChip`, `RadioListTile`, `showModalBottomSheet`) plus the existing `design_system` widgets.
- **Batch your work:** write all the files of a step, wire them up, then run `flutter analyze` **once** for the app and the touched packages, and fix every error.
- **No tests.** Don't write or run them, and don't add test packages.
- **Don't stop for confirmation,** don't refactor working code, and don't ask questions. Make an assumption, write it in `apps/pharmmed/DEMO_NOTES.md`, and continue.
- **If something takes more than ~10 minutes,** build the simplest working version, add `// TODO(polish):`, and move on.
- **Absolute paths only** for every file write: `/Users/primesysindia/priyanshuprimesys/PersonalFolder/projects/pharmaapp/...`. Packages live in `<root>/packages/...`, **never** in `apps/packages/`.
- **A screen is done only when it's reachable in the running app.** After each step, tick `apps/pharmmed/PHASES.md` and post 3 lines: what's visible now, how to reach it, and the analyze result.

## What exists today (inspected — reuse it, match these exact APIs)

**`core`** (`packages/core/lib/src/`)
- `Result<T>` with `Success`/`Failure`. Check `result.dart` for the exact constructors. The broken cart file calls `Result.failure('code', [...])` and `Result.success(...)`; use whatever actually exists.
- `formatPaise(int)` money formatter.
- `RoutePaths`: `home '/'`, `categories '/categories'`, `cart '/cart'`, `orders '/orders'`, `profile '/profile'`, `search '/categories/search'`, `productDetailBase '/categories/product'`, `orderDetailBase '/orders'`, `login '/login'`, `checkout '/checkout'`, `checkoutSuccess '/checkout/success'`, `uiKit '/ui-kit'`, `productDetail(id)`, `orderDetail(id)`.
- `AuthSession`: `bool isLoggedIn`, `String? userName`, `Stream<bool> authChanges`, `Future<Result<SessionInfo>> login({identifier, password})`, `void logout()`. `SessionInfo(userName, identifier)`.
- `PaymentGateway`: `Future<Result<PaymentReceipt>> pay({amountPaise, orderId, method})`. `PaymentReceipt(transactionId, method, paidAt)`.
- `KeyValueStore`: `read(key)`, `write(key, value)`, `delete(key)`, all `Future`.

**`shared_models`**
- `Product`: id, name, genericName, salt, manufacturer, categoryId, packSize, `int mrp`, `int price`, requiresPrescription, inStock, description, uses, sideEffects, storage, `imageAsset?`, `discountPercent`, `hasDiscount`, `toJson`/`fromJson`.
- `CartItem`: product, qty, `productId`, `lineMrpTotal`, `lineTotal`, `copyWith(qty)`, `toJson`/`fromJson`.
- `Category`: id, name, imageAsset, iconKey.
- `Address`: id, fullName, phone, pincode, line1, city, `summary`.
- `Order`: id, items, address, slot, paymentMethod, breakdown, createdAt, status, `itemCount`. `PaymentMethod { cod('Cash on Delivery'), upi('UPI (demo)') }`, `OrderStatus { placed('Placed') }`.
- `PriceBreakdown`: itemMrpTotal, sellingTotal, discount, couponDiscount, deliveryFee, payable, couponCode?, `PriceBreakdown.empty()`.
- `Money`: `format(paise)`, `rupees(int)`, `percentOf(paise, percent)`.
- `CartRepository`: `maxQuantityPerItem = 10`, `items`, `watch()`, `add(product, {qty})`, `updateQty(productId, qty)`, `remove(productId)`, `clear()`, all returning `Future<Result<List<CartItem>>>`.
- `CatalogRepository`: `getCategories()`, `getProducts({categoryId})`, `getProduct(id)`, `searchProducts(query)`.

**`design_system`**: theme, `AppColors`, `AppSpacing`, `AppTypography`, `AppButton`, `EmptyState`, `LoadingView`, `PriceText`, `ProductImage`, `QuantityStepper`, `RxBadge`, `ShimmerBox`, `AnimatedCountText`, `BadgePop`, `StaggeredFadeIn`.

**`feature_catalog`** (working): demo datasource (~30 medicines), `DemoCatalogRepository`, `registerCatalogModule`, `CategoriesPage`, `CategoryProductsPage`, `SearchPage`, `ProductDetailPage` (reads `id` from `GoRouterState`), `ProductCard(product, qty, onAdd, onQtyChanged, onTap, icon)`, `ProductListSkeleton`.

**`feature_auth`**: `LoginPage`, `RegistrationPage`, `AuthFlow` (UI only, no session).

**App** (`apps/pharmmed/lib/app/`): `app.dart`, `router/app_router.dart`, `di/injector.dart` (only `registerCatalogModule` is active), `shell/app_shell.dart`, `shell/placeholder_page.dart`, `debug/ui_kit_*`. The app's `pubspec.yaml` depends only on `core`, `design_system`, `go_router`, `get_it` and `feature_catalog`.

**Images** in `apps/pharmmed/assets/images/`:
- banners: `pharmacy_shelf.jpg`, `family_health.jpg`, `pills_capsules.jpg`
- categories: 8 images, one per category
- products: `tablet_strip`, `tablet_bottle`, `syrup_bottle`, `cream_tube`, `capsules`
- illustrations: `empty_cart.jpg`, `order_success.jpg`

## Known bugs to fix first (Step 0)

1. **`packages/features/feature_cart/lib/src/repositories/in_memory_cart_repository.dart` is broken.** It imports `../models/...` paths that don't exist and has `const <CartItem>[].watch()`. Delete it; Step 2 replaces it with a real repository.
2. **`feature_catalog/pubspec.yaml` is missing dependencies** on `core`, `design_system`, `get_it` and `go_router`. Add them. Also remove the self-export line `export 'package:feature_catalog/feature_catalog.dart';` from its barrel.
3. **Router sub-routes under `/categories` use absolute paths.** Child `GoRoute` paths must be **relative**:
   - `path: 'search'` (full URL `/categories/search`)
   - `path: 'product/:id'` (full URL `/categories/product/:id`)
   - add `path: ':categoryId'` → `CategoryProductsPage`, declared **after** `search` and `product/:id` so those match first
4. **No `CartRepository` is registered in DI,** so tapping "Add" crashes. Step 2 fixes this.
5. Replace `RoutePaths.productDetailBase + '/:id'` string concatenation with interpolation (analyzer info).

## Shared building blocks (Step 1 — do this before the screens)

- **Move `ProductCard` to `design_system`** (`lib/src/widgets/product_card.dart`). Home, Catalog and Cart all need it, and features must not import each other.
  - Make it take a `Product` (`design_system` already may depend on `shared_models`; if not, add the dependency), `qty`, `onAdd`, `onQtyChanged`, `onTap` and `icon`.
  - Show: `ProductImage` with a `Hero` tag `product-${id}`, name (2 lines max), pack size, `PriceText` (MRP struck out + price), a green "xx% off" label, `RxBadge` if Rx, and an Add button that morphs to `QuantityStepper` (`AnimatedSwitcher`). Out of stock → a disabled "Out of stock".
  - Add a `compact` variant (fixed width ~150) for horizontal rows.
  - Update `feature_catalog` to import it from `design_system` and delete its local copy.
- **Add `SectionHeader(title, actionLabel?, onAction?)`** to `design_system` ("Popular medicines ... See all").
- **Add `CartIconButton`** to `design_system`: a cart icon + count badge with `BadgePop`. It takes a `count` and an `onTap`.
- **Add `OrdersRepository`** to `shared_models/lib/src/repositories/orders_repository.dart`: `Future<Result<Order>> place(Order order)`, `Future<Result<List<Order>>> getOrders()` (newest first), `Future<Result<Order?>> getOrder(String id)`, `Stream<List<Order>> watch()`. Export it.
- **Add `AddressRepository`** to `shared_models`: `List<Address> get addresses`, `Address add(Address)`, `Address? selected`, `void select(String id)`, `Stream<Address?> watchSelected()`. The Home header and Checkout share it.
- **Add a `PricingCalculator`** (pure Dart) to `shared_models`: `PriceBreakdown calculate(List<CartItem> items, {String? couponCode})` and `CouponResult validateCoupon(String code, int sellingTotal)`.
  - `PHARMA10`: 10% off the selling total, capped at ₹100.
  - `FIRST50`: ₹50 off when the selling total is ≥ ₹300.
  - Codes are trimmed and case-insensitive. Unknown code → an error message. A code below its minimum → an error with "Add ₹X more to use FIRST50".
  - Delivery is free when the payable before delivery is **above ₹499**, else ₹40.
  - Everything in `int` paise.

## Steps — build these screens in this order

### Step 2 — Cart (`packages/features/feature_cart`)

**Files**
- `lib/src/data/persisted_cart_repository.dart`: `implements CartRepository`. Load from `KeyValueStore` key `cart_v1` (JSON list of `CartItem.toJson()`); corrupt JSON → empty cart. Every change saves and emits on a broadcast `StreamController`. `watch()` first emits the current items. `add`/`updateQty` above 10 → `Failure` with the message "You can add up to 10 of an item". `updateQty(id, 0)` removes the item.
- `lib/src/presentation/state/cart_cubit.dart` + `cart_state.dart`. The state holds `items`, `breakdown`, `couponCode`, `couponError`, `rxCount`, `limitMessage` (one-shot) and `status`. Methods: `increment(id)`, `decrement(id)`, `remove(id)`, `applyCoupon(code)`, `removeCoupon()`, `clearLimitMessage()`. It listens to `repository.watch()` and recomputes through `PricingCalculator`.
- `lib/src/presentation/pages/cart_page.dart`
- `lib/src/presentation/widgets/cart_line_tile.dart`, `coupon_section.dart`, `bill_details_card.dart`, `rx_banner.dart`, `cart_bottom_bar.dart`
- `lib/src/di/cart_module.dart`: `registerCartModule(GetIt)` registers `CartRepository` → `PersistedCartRepository` as a lazy singleton.
- `packages/database/lib/src/shared_prefs_key_value_store.dart`: `implements KeyValueStore` using `shared_preferences`. Export it from `database.dart`. Add `shared_preferences` to the `database` pubspec.

**Cart page UI (top to bottom)**
1. AppBar "My Cart (N items)".
2. **Rx banner** (amber card, document icon): "Prescription required for N item(s). You can upload it at checkout." Only shown if `rxCount > 0`.
3. **Line items**, one `Card` each:
   - 64×64 `ProductImage`, name, pack size, `RxBadge` if Rx
   - `PriceText` (MRP struck out + price), "xx% off"
   - `QuantityStepper` (min 1, max 10) on the right, with the line total under it
   - a "Remove" text button (trash icon)
   - swipe left to remove (`Dismissible` with a red background), showing a snackbar with an **"Undo"** action that re-adds the item
4. **Savings strip** (green): "You're saving ₹X on this order" (MRP discount + coupon).
5. **Coupon section**:
   - a `TextField` "Enter coupon code" + "Apply"
   - below it, two tappable suggestion chips: `PHARMA10` "10% off up to ₹100" and `FIRST50` "₹50 off on ₹300+"
   - success → a green tile "✓ PHARMA10 applied — you saved ₹X" with a short scale animation and a "Remove" link
   - error → red helper text under the field
6. **Bill details card**: Item total (MRP), Product discount (−), Coupon discount (−, only if applied), Delivery fee ("FREE" in green, or ₹40 with the hint "Add ₹X more for free delivery"), divider, **To pay** in bold. Every amount uses `AnimatedCountText`.
7. A "Continue shopping" text button.
8. **Sticky bottom bar** (`bottomNavigationBar` of the page `Scaffold`): left side shows "₹X" bold + "View bill details" (scrolls to the bill card); right side has a `FilledButton` "Proceed to checkout" → `context.push(RoutePaths.checkout)`.

**Empty cart:** `EmptyState` with `empty_cart.jpg`, "Your cart is empty", "Add medicines to get started", and a "Browse medicines" button → `context.go(RoutePaths.categories)`. Pass the image path from the app (a constant in the app passed through the page constructor) so the feature doesn't hard-code asset paths.

**Cart badge:** `AppShell` listens to `CartRepository.watch()` (a `StreamBuilder` is fine) and shows the count on the Cart tab icon with `BadgePop`. Use the same count for `CartIconButton` in the Home header and the product detail AppBar.

**Wire it:** add `feature_cart` and `database` to the app pubspec. In `injector.dart`, initialize `SharedPreferences` (make `configureDependencies` `async` and `await` it in `main`), register `KeyValueStore` → `SharedPrefsKeyValueStore`, then call `registerCartModule(getIt)`. Route the Cart tab → `CartPage`. The catalog's Add buttons now use the real repository.

**Visible result:** add from Categories → the badge pops → the Cart tab shows items, coupons and the bill → kill and relaunch the app, and the items are still there.

---

### Step 3 — Home (`packages/features/feature_home`)

**Files**
- `lib/src/presentation/state/home_cubit.dart` + `home_state.dart`: loads categories and all products through `CatalogRepository`. Derives `deals` (the 6 highest `discountPercent` in stock), `popular` (a fixed id list or the first 8 in stock), `recommended` (the rest), and `brands` (distinct `manufacturer`). The state also has `status` (loading/loaded/error).
- `lib/src/presentation/pages/home_page.dart`
- `lib/src/presentation/widgets/home_header.dart`, `address_selector_sheet.dart`, `quick_actions_row.dart`, `banner_carousel.dart`, `category_grid.dart`, `deals_row.dart`, `product_row.dart`, `brands_row.dart`, `trust_strip.dart`, `home_skeleton.dart`
- `lib/src/di/home_module.dart`: `registerHomeModule(GetIt)` (a cubit factory, if you use one)
- Banner data: a small `HomeBanner(imageAsset, title, subtitle, ctaLabel, categoryId?)` list passed in from the app, so the asset paths stay in the app.

**Home page UI** (a `CustomScrollView`, top to bottom)
1. **Header** (`SliverAppBar`, teal background, `pinned: true`, `floating: true`, expandedHeight ~150):
   - **Top row:** a "PharmMed" wordmark (bold white text + a pill icon), and on the right a notifications icon (snackbar "No new notifications") and `CartIconButton` → Cart tab.
   - **Second row:** 📍 "Deliver to **Rahul** — Mumbai 400001 ▾" (from `AddressRepository.selected`). Tapping it opens `address_selector_sheet`, which lists the demo addresses as `RadioListTile`s, and selecting one updates the header.
   - **Pinned bottom** (`PreferredSize`): a white rounded search box with a search icon, the hint "Search for medicines & health products" and a mic icon (decorative). Tapping anywhere → `context.push(RoutePaths.search)`.
2. **Quick actions row** (4 equal cards with an icon + label):
   - "Order with prescription" → snackbar "Upload at checkout"
   - "Reorder" → Orders tab
   - "Offers" → scroll to the deals section
   - "Lab tests" → snackbar "Coming soon"
3. **Banner carousel:** a `PageView` of ~160 high rounded cards using the 3 banner images.
   - Each card has a dark gradient overlay plus white text: "Flat 20% off on medicines" / "Use code PHARMA10"; "Free delivery above ₹499" / "On all orders"; "Vitamins & supplements" / "Boost your immunity". Each also has a small "Shop now" chip that opens the matching category.
   - Auto-advance every 4 s with `animateToPage` (300 ms, `easeOutCubic`), and loop. Animated dots underneath (the active dot is wider). Pause while the user is dragging.
4. **"Shop by category"** `SectionHeader` with "See all" → Categories tab. A 4×2 grid: circular 64 px `ProductImage` of the category image on a light teal circle, with the name under it (2 lines, centered, small). Tap → `context.push('/categories/${category.id}')`.
5. **"Deals of the day"** `SectionHeader` + a red chip "Ends in HH:MM:SS" (a `Timer.periodic` counting down to midnight, cancelled in `dispose`). A horizontal `ListView` of compact `ProductCard`s with a "xx% OFF" ribbon in the corner.
6. **"Popular medicines"** `SectionHeader` ("See all" → Categories). A horizontal row of compact `ProductCard`s. Add → stepper, synced with the cart.
7. **Promo strip:** a full-width teal-tint card, "Get ₹50 off on your first order — use FIRST50", with a copy icon (copies to clipboard and shows a snackbar).
8. **"Trusted brands":** a horizontal row of rounded chips showing the manufacturer name and an initial avatar. Tapping one opens search prefilled with the brand (`/categories/search?q=<brand>`; make `SearchPage` read the `q` query param).
9. **"Recommended for you":** a `SliverGrid`, 2 columns, `childAspectRatio` ~0.62, with the full `ProductCard`.
10. **Trust strip:** 3 icons in a row: "100% genuine", "Licensed pharmacy", "Secure payments". Then bottom padding.

All product cards read the cart qty from `CartRepository.watch()` and call `add`/`updateQty`. Tapping a card → `context.push(RoutePaths.productDetail(id))`. Loading → `home_skeleton` (shimmer blocks for the banner, the grid and 2 rows). Error → `EmptyState` with "Retry". Wrap the sections in `StaggeredFadeIn`.

**Wire it:** add `feature_home` to the app pubspec. Register the demo `AddressRepository` (in-memory, 2 addresses: "Rahul Sharma, 9876543210, 12 MG Road, Andheri, Mumbai 400053" and "Rahul Sharma, 9876543210, 45 Park Street, Pune 411001", the first one selected) in the app's DI or a small `feature_checkout` data file. Register the home module. Route the Home tab → `HomePage`.

**Visible result:** the app opens on a rich Home, and every section, tile, banner, chip and the search bar navigates or responds.

---

### Step 4 — Checkout + login gate + order success (`feature_checkout`, `feature_auth`, `authentication`)

**Auth**
- `packages/authentication/lib/src/demo_auth_session.dart` `implements AuthSession`. `login` succeeds for any non-empty identifier + password, after a 600 ms delay. The `userName` is derived from the identifier (an email's local part capitalized, or "Customer" for a phone number). The session stays in memory, and `authChanges` is a broadcast stream. Export it and register it in DI as a singleton.
- `feature_auth`: make `LoginPage` usable as a route.
  - It gets an `AuthSession` (from `GetIt` or a constructor) and calls `login`.
  - It shows field errors for empty input and a loading state on the button.
  - On success it calls `context.pop(true)`. Add a header "Log in to place your order".
  - "Create account" opens `RegistrationPage`, which on submit also logs in and pops `true`.
  - Route `RoutePaths.login` as a **top-level** route, so it covers the bottom nav.

**Checkout files** (`packages/features/feature_checkout/lib/src/`)
- `domain/place_order_use_case.dart`:
  1. `Failure('empty_cart')` if the cart is empty.
  2. `Failure('prescription_required', 'Please upload a prescription for Rx medicines')` if any item `requiresPrescription` and `prescriptionAttached == false`.
  3. `Failure('no_address')` if no address is selected.
  4. Calls `PaymentGateway.pay`.
  5. Builds an `Order` with id `'PM${DateTime.now().millisecondsSinceEpoch}'`, status placed, and the breakdown from `PricingCalculator` with the cart's coupon.
  6. `OrdersRepository.place`, then `CartRepository.clear()`.
  7. Returns `Success(order)`.

  This is the domain rule, so the button being disabled is not enough.
- `data/demo_payment_gateway.dart` `implements PaymentGateway`: `cod` succeeds immediately; `upi` waits 1.5 s and then succeeds. The transaction id is `TXN<timestamp>`.
- `data/in_memory_orders_repository.dart` `implements OrdersRepository` (newest first, broadcast stream). It lives here, or in `feature_orders`, as long as the app DI registers a single instance.
- `presentation/state/checkout_cubit.dart` + `checkout_state.dart`. The state holds `addresses`, `selectedAddressId`, `slotDay` (today/tomorrow), `slotTime` (morning 8–12 / evening 4–8), `paymentMethod`, `prescriptionAttached`, `hasRx`, `breakdown`, `placing`, `error` and `placedOrder`. Methods: `selectAddress`, `addAddress`, `selectSlot`, `selectPayment`, `attachPrescription`, `removePrescription`, `placeOrder()`.
- `presentation/pages/checkout_page.dart`, `add_address_page.dart`, `order_success_page.dart`
- `presentation/widgets/checkout_section_card.dart`, `address_card.dart`, `slot_picker.dart`, `prescription_section.dart`, `payment_options.dart`, `order_summary_card.dart`, `place_order_bar.dart`, `success_check_animation.dart`
- `di/checkout_module.dart`: `registerCheckoutModule(GetIt)`

**Checkout page UI** (AppBar "Checkout", scrollable, numbered section cards)
1. **"1. Delivery address":** address cards as radio tiles (name, phone, `summary`), with the selected one highlighted by a teal border. Below them, "+ Add new address" → `AddAddressPage`, a form with: Full name (required); Phone (exactly 10 digits, `TextInputType.phone`, digits only); Pincode (exactly 6 digits); House/Street (required); City (required). A "Save address" button. On save it pops the new address and the cubit adds and selects it.
2. **"2. Delivery slot":** two `ChoiceChip`s for the day ("Today, 29 Oct" / "Tomorrow, 30 Oct", computed) and two for the time ("Morning 8 AM–12 PM" / "Evening 4 PM–8 PM").
3. **"3. Prescription"** (only if `hasRx`): "N item(s) in your cart need a valid prescription".
   - Not attached: an outlined "Upload prescription" button with a camera/document icon. Tapping it shows a bottom sheet "Take photo / Choose from gallery". Both just mark it attached (a mock).
   - Attached: a 64×64 thumbnail placeholder (a document icon on a grey rounded box), "prescription_demo.jpg", a green "Attached" chip and a "Remove" link.
4. **"4. Payment method":** `RadioListTile`s for "Cash on Delivery" (cash icon) and "UPI (demo)" (QR icon, with the subtitle "Simulated payment, no money is charged").
5. **"5. Order summary":** a collapsible list of items (name × qty, line total), then the bill (Item total, Discount, Coupon, Delivery, **To pay**), and the coupon code if applied.
6. **Sticky `place_order_bar`:** "To pay ₹X" + a `FilledButton` "Place order".
   - Disabled while `placing` (it shows a spinner, and "Processing UPI payment…" for UPI).
   - On tap: if `!authSession.isLoggedIn`, `final ok = await context.push<bool>(RoutePaths.login)`. If `ok != true`, stop and show the snackbar "Please log in to place your order". Then call `cubit.placeOrder()`.
   - `Failure` → a red snackbar with the message; for `prescription_required`, also scroll to the prescription section.
   - `Success` → `context.go('${RoutePaths.checkoutSuccess}?id=${order.id}')`.

**Order success page** (top-level route, no bottom nav, back button disabled with `PopScope`):
- an animated green check (a circle scales in with `elasticOut`, then the check fades in) over `order_success.jpg`, or the check alone
- "Order placed successfully!" and "Order ID: PM…" (with a copy icon)
- "Arriving by <Tomorrow / day after, 8 PM>" computed from the slot, and "Pay ₹X on delivery" or "Paid via UPI"
- buttons: `FilledButton` "View order" → `context.go(RoutePaths.orderDetail(id))`; `OutlinedButton` "Continue shopping" → `context.go(RoutePaths.home)`

**Wire it:** add `feature_checkout`, `feature_auth` and `authentication` to the app pubspec. Register `AuthSession` → `DemoAuthSession`, `PaymentGateway` → `DemoPaymentGateway`, `OrdersRepository` → `InMemoryOrdersRepository` and the checkout module. Add top-level routes for `RoutePaths.checkout`, `checkout/address/new` (or push the page directly), `RoutePaths.checkoutSuccess` and `RoutePaths.login`.

**Visible result:** cart → Proceed to checkout → address + slot + COD → Place order → login (any input) → success. An Rx cart shows the error until the prescription is attached.

---

### Step 5 — Orders (`packages/features/feature_orders`)

**Files:** `presentation/state/orders_cubit.dart` (watches `OrdersRepository`), `order_detail_cubit.dart`, `pages/orders_page.dart`, `pages/order_detail_page.dart`, `widgets/order_card.dart`, `widgets/order_status_timeline.dart`, `di/orders_module.dart`.

**Orders page:** AppBar "My Orders".
- **Empty:** `EmptyState` "No orders yet", "Your placed orders will appear here", button "Start shopping" → Home.
- **List** (newest first). Each `order_card` shows:
  - "Order #PM…" with the date ("29 Oct 2026, 4:15 PM")
  - a status chip "Placed" (teal)
  - a row of up to 3 small product thumbnails, plus "+N" if there are more
  - "N items · ₹X"
  - a "View details ›" button, and a "Reorder" text button that adds all items back to the cart and shows the snackbar "Items added to cart"
  - tapping the card → `context.push(RoutePaths.orderDetail(id))`

**Order detail page:** AppBar "Order #PM…".
- **Status timeline** (vertical): Placed ✓ (active, with the time), Packed, Shipped, Delivered (grey, pending).
- **"Items":** each line has a thumbnail, name, qty × price and the line total.
- **"Delivery address":** name, phone and `summary`. **"Delivery slot":** the slot text.
- **"Payment":** the method label, plus "Paid" (UPI) or "Pay on delivery" (COD).
- **"Bill details":** the same rows as the cart, ending with **"Total paid / To pay"**.
- Bottom buttons: "Need help?" (snackbar) and "Reorder".

**Wire it:** route the Orders tab → `OrdersPage`, with the child route `':id'` → `OrderDetailPage` (relative path). Add `feature_orders` to the app pubspec and register the module.

---

### Step 6 — Profile (`packages/features/feature_profile`)

**Files:** `presentation/state/profile_cubit.dart` (listens to `AuthSession.authChanges`), `pages/profile_page.dart`, `pages/saved_addresses_page.dart`, `widgets/profile_header.dart`, `widgets/profile_menu_tile.dart`, `di/profile_module.dart`.

**Profile page:**
- **Header card** (teal gradient):
  - **Signed out:** an avatar with a person icon, "Hello, Guest", "Log in to see your orders and save addresses", and a white `FilledButton` "Log in / Sign up" → `context.push(RoutePaths.login)`.
  - **Signed in:** an avatar with the initial, the user name, the identifier (phone/email) and an "Edit" icon (snackbar).
- **Menu list** (`ListTile`s with leading icons and a chevron):
  - "My orders" → Orders tab
  - "Saved addresses" → `SavedAddressesPage`: lists the `AddressRepository` addresses and has an "Add new address" button that reuses the checkout form route, or a simple copy of it
  - "My prescriptions" → snackbar "Coming soon"
  - "Offers & coupons" → a bottom sheet listing PHARMA10 and FIRST50 with their rules
  - "Help & support" → a bottom sheet with a demo phone/email
  - "About PharmMed" → `showAboutDialog`
  - (debug only, `kDebugMode`) "UI kit" → `RoutePaths.uiKit`
- **Signed in only:** a red outlined "Log out" button. It shows a confirm dialog, then `authSession.logout()`, and the header switches back to Guest.
- App version text at the bottom ("v1.0.0 (demo)").

**Wire it:** route the Profile tab → `ProfilePage`. Add `feature_profile` to the app pubspec and register the module. **Delete `shell/placeholder_page.dart`.** No placeholder may remain.

---

### Step 7 — Product detail upgrade + final polish

- **`ProductDetailPage`** (`feature_catalog`):
  - AppBar with `CartIconButton`
  - a large `Hero` image on a light background, name, manufacturer ("by Micro Labs"), pack size, `RxBadge`
  - `PriceText` + "xx% off" + "Inclusive of all taxes"
  - an **"Add to cart"** button that becomes `QuantityStepper` + a "Go to cart" button once added
  - expandable sections (`ExpansionTile`): Description, Salt composition, Uses, Side effects, Storage
  - "Substitutes" horizontal row (same salt, excluding itself)
  - a delivery info row: "Delivery by tomorrow", "Free delivery above ₹499"
  - out of stock → a disabled "Out of stock" button and a "Notify me" outline button (snackbar)
- **`CategoryProductsPage`:** a sort bottom sheet (Relevance, Price low→high, Price high→low, Name A–Z), filter chips (All / OTC / Rx), and the 2-column grid with the full `ProductCard`.
- **Page transitions:** one fade-through `CustomTransitionPage` (250 ms) for all pushed routes.
- **Accessibility:** the animation widgets respect `MediaQuery.disableAnimations`.
- **Docs:**
  - `apps/pharmmed/assets/images/CREDITS.md` (the source URL and license of every image)
  - `apps/pharmmed/DEMO_NOTES.md`: demo coupons, demo login (any non-empty value), demo addresses, assumptions, and how to swap in a real API (new datasource + DI change only)
- **Build:** run `flutter analyze` (zero errors in the app and every touched package) and `flutter build apk --debug`.

## Final acceptance walkthrough (report pass/fail for each)

1. The app opens on the rich Home: header with address, search, banners, categories, deals, popular, brands, recommended.
2. Search "dolo" → Dolo 650 → detail with a Hero → add 2 → the badge shows 2.
3. Cart: totals are correct. `PHARMA10` applies (capped at ₹100), an invalid code shows an error, and the free-delivery hint updates.
4. Checkout: pick an address, add a new address (validation works), pick a slot, choose COD → Place order → the login screen appears → log in with anything → the success screen shows the order id.
5. The cart is empty. Orders shows the order, and its detail shows the items, address, slot, payment and bill.
6. Adding an Rx item (e.g. Glycomet 500) → Place order is blocked with the prescription error until it's attached.
7. UPI (demo) shows ~1.5 s of processing, then success.
8. Profile shows the name and "Log out". After logging out it shows "Hello, Guest".
9. Kill and relaunch the app: the cart is still there.
10. There is no `PlaceholderPage` anywhere and no HTTP calls, `flutter analyze` is clean, and no `double` is used for money.

## Architecture rules

- **State:** `flutter_bloc` Cubits. **DI:** `get_it` only (no `injectable`/`build_runner`). Each feature exposes `registerXModule(GetIt)`, and `apps/pharmmed/lib/app/di/injector.dart` calls them all.
- **Routing:** `go_router` `StatefulShellRoute.indexedStack` with 5 tabs (Home · Categories · Cart · Orders · Profile). Paths come from `RoutePaths`. **Child routes use relative paths.** Checkout, login and success are top-level routes (no bottom nav).
- **Features never import each other.** They share only `core`, `shared_models` and `design_system`. Cross-feature navigation is **by route path only**, and implementations are wired in the app's DI.
- **Every package declares in its own `pubspec.yaml` every package it imports.**
- **Models:** plain immutable classes + `equatable`. **Money:** `int` paise only.
- One page or widget per file. Keep files under ~250 lines.
- Don't modify `pharmaadmin` or `pharmabtob`. Add only the packages you use (`flutter_bloc`, `equatable`, `shared_preferences`).
