# Prompt: Add Tests for the `pharmmed` Shopping Flow

> Copy everything below the line into your AI coding assistant (run it from the repo root).
> Run this **after** `PHARMMED_SHOPPING_PROMPT.md` is finished (all 6 steps done, `flutter build apk --debug` passing).

---

## Role

You are a senior Flutter engineer. The `pharmmed` customer shopping flow is built (Home → Catalog → Cart → Checkout → Orders/Profile, with demo data). It has almost no tests, because they were skipped to ship faster. Add **focused, useful tests** for every screen, cubit, use case, repository and pure function that holds real logic. Skip anything trivial.

## Step 0 — Inventory first (no test code yet)

1. Read `apps/pharmmed/PHASES.md`, `apps/pharmmed/DEMO_NOTES.md`, every `pubspec.yaml`, and the `lib/` folders of `core`, `shared_models`, `design_system`, `database`, `feature_catalog`, `feature_cart`, `feature_home`, `feature_checkout`, `feature_orders`, `feature_profile`, `feature_auth`, and `apps/pharmmed/lib/app/`.
2. Read the tests that already exist (`packages/core/test/`, `packages/shared_models/test/`, `packages/design_system/test/`, `packages/features/feature_auth/test/`) and run `flutter test` in each to see what passes today.
3. Post a **test plan table** listing every class or method that needs a test, then start writing tests straight away (don't wait for my reply):

   | Package | File under test | Class / method | Test type (unit / cubit / widget) | Cases |
   |---|---|---|---|---|

Use the **real names in the code**, not the names in this prompt. If a name below doesn't exist, find the class that does that job.

## What must be covered

The rule for deciding: **test anything with a branch, a calculation, a validation, a state transition, or a user-visible conditional.** Skip pure layout widgets, simple getters, `toString`, theme tokens and the `Demo…DataSource` data itself (beyond one sanity test).

### Unit tests (pure Dart)
- **`core`**
  - Money formatter: 0, < ₹1, ₹1,234.50, lakhs grouping (₹1,23,456.00 or whatever format the code uses, so read it first), negative values if supported.
  - `Result`: `Success`/`Failure` folding/mapping helpers, if any.
- **`shared_models`**
  - Every model's `==`/`props`, and `copyWith` if present.
  - `CartItem` and cart JSON: `toJson` → `fromJson` round trip, and malformed or missing JSON fields.
  - `PriceBreakdown` (or the calculator that builds it):
    - MRP total, discount, payable
    - delivery fee at ₹498.99, ₹499.00 and ₹499.01 (free **above** ₹499, else ₹40), using exact paise boundaries
    - empty cart
  - Coupons:
    - `PHARMA10` gives 10% off, capped at ₹100: test below the cap, exactly at the cap, and above the cap
    - `FIRST50` gives ₹50 off on orders ≥ ₹300: test ₹299.99 (rejected), ₹300 and above
    - invalid code, lower-case input, and whitespace input (match whatever the code intends)
    - removing a coupon
  - No `double` used for money. Every expected value is in `int` paise.
- **`feature_catalog`**
  - Search matching by brand, generic name and salt; case-insensitive; partial match; no match; empty query.
    - "dolo" finds Dolo 650; "paracetamol" finds several.
  - Sort (price ↑, price ↓, name) and filter (OTC only / Rx).
  - Substitutes: products with the same salt, excluding the product itself.
  - Repository: returns `Success` with data and maps datasource errors to `Failure`.
- **`feature_cart`**
  - `PersistedCartRepository` against a fake `KeyValueStore`:
    - add, remove, updateQty, clear
    - `watch()` emits the new state after each change
    - a new instance reloads saved items (the "survives relaunch" check)
    - corrupt stored JSON leads to an empty cart, not a crash
  - Quantity limit: 10 per item. Adding past 10 is rejected (`Failure` or a flag, whichever the code uses).
- **`feature_checkout`**
  - Rx rule: placing an order with an Rx item and no prescription fails; with a prescription it succeeds; an OTC-only cart needs no prescription.
  - Address form validators: name required, phone exactly 10 digits, pincode exactly 6 digits, address line and city required.
  - Order id format starts with `PM` followed by a timestamp. Use an injected clock if one exists; if not, only assert the prefix and that the rest is digits.
  - `DemoPaymentGateway`: COD succeeds immediately; UPI succeeds after a delay (use `fakeAsync`, not real waiting).
  - The cart is cleared after a successful order.
- **`feature_auth` / app**
  - `DemoAuthSession`: login accepts any non-empty credentials and rejects empty ones; the `isLoggedIn` stream emits on login and on logout.
- **`feature_orders`**
  - In-memory orders repository: new orders come first (newest first) and have status "Placed".

### Cubit tests (`bloc_test`)
For **each** cubit in the app: initial state, the loading → loaded path, the error path, and every public method. At least:
- Catalog list cubit: load by category, sort change, filter change.
- Catalog search cubit: debounce. Typing 3 characters quickly triggers **one** search after 300 ms. Use `wait:` or `fakeAsync`. Also test the empty result and clearing the query.
- Product detail cubit: load, not found, out of stock.
- Cart cubit:
  - add, increment, decrement to 0 (which removes the item)
  - the limit-hit state or event (the trigger for the snackbar)
  - coupon apply success, coupon invalid error, coupon removal
  - Rx count
- Home cubit: categories and popular items load, and the error path.
- Checkout cubit:
  - select address, add address, select slot, attach prescription, select payment
  - place order as a guest, which emits the "login required" state
  - place order when logged in, which succeeds
  - Rx blocked
  - UPI loading state
- Orders cubit and Profile/auth cubit: signed-out ↔ signed-in transitions.

### Widget tests
Give each page or widget a test when it has conditional UI or user interaction:
- **design_system**: `QuantityStepper` (+/− callbacks, disabled at min/max), `ProductImage` falls back on a missing asset or a null path, `PriceText` shows MRP struck out and the discount %, `RxBadge` shown or hidden, `EmptyState` button callback. Keep or extend the tests that already exist.
- **ProductCard**: tapping Add swaps it for a stepper (the AnimatedSwitcher morph; use `pumpAndSettle`), the Rx badge shows for Rx items, and out-of-stock items show a disabled button.
- **Home page**: renders all 8 categories, the banners and the popular row; tapping the search bar navigates to the search route; tapping a category navigates to that category.
- **Search page**: typing shows results after the debounce; a query with no match shows the empty state.
- **Product detail page**: shows salt, uses, side effects and substitutes; "Add to cart" calls the repository; "Go to cart" navigates.
- **Cart page**:
  - the empty state with a "Browse medicines" button
  - line items and totals
  - a snackbar at the qty limit
  - swipe to remove
  - the Rx banner text "Prescription required for N item(s)"
  - the coupon error message
- **Checkout page**:
  - the prescription step appears only for an Rx cart
  - Place order stays blocked until the prescription is attached
  - the address form shows validation errors
  - as a guest, Place order navigates to the login route
- **Order success page**: shows the order id and both buttons navigate.
- **Orders list and detail**: the empty state; an order's details render.
- **Profile page**: "Guest" + "Log in" when signed out; the name + "Log out" when signed in.
- **Login page** (`feature_auth`): empty fields show errors; valid input calls the session.
- **App shell** (`apps/pharmmed/test/`): the app starts on Home (no login screen), all 5 tabs switch, and the cart badge count updates when an item is added.

## Conventions

- **Packages:** add `bloc_test` and `mocktail` as `dev_dependencies` only in the packages that use them. Prefer **hand-written fakes** (e.g. `FakeCartRepository`, `InMemoryKeyValueStore`) over mocks for repositories and stores. Use `mocktail` only to verify calls.
- **Location:** `test/` mirrors `lib/src/` (e.g. `lib/src/presentation/state/cart_cubit.dart` → `test/presentation/state/cart_cubit_test.dart`). One test file per class under test.
- **Shared helpers:** if several test files in a package need them, put them in that package's `test/helpers/`:
  - `pumpApp(tester, widget)`, which wraps the widget in `MaterialApp` with `AppTheme` and any needed `BlocProvider`s
  - a test `GoRouter` for navigation assertions
  - test data builders like `buildProduct({...})`
- **No real waiting:** don't use real `Future.delayed` in tests. Inject a zero delay into the `Demo…DataSource` (add a constructor `Duration delay` param defaulting to the demo value if it doesn't exist), or use `fakeAsync` / `tester.pump(duration)`.
- **shared_preferences:** use `SharedPreferences.setMockInitialValues({})` only when testing the real `SharedPreferencesKeyValueStore`. Everything else uses the in-memory fake.
- **GetIt:** call `GetIt.instance.reset()` in `tearDown` for any test that touches DI.
- **Animations:** use `pumpAndSettle` after interactions. For auto-scrolling banners or repeating shimmer, `pumpAndSettle` will time out, so use `pump(Duration)` instead.
- **Names:** `group('CartCubit', ...)` → `test('emits limit reached when qty exceeds 10', ...)`. Each test checks one behavior.
- **Testability changes:** small refactors are allowed, such as injecting a clock, delay or datasource through the constructor, or adding `Key`s to widgets you need to find. Don't change behavior.
- **Bugs:** if a test exposes a real bug, fix the production code, keep the test, and list the fix in the report. Never weaken a test to make it pass.

## Work order

1. Pure unit tests: `core`, `shared_models`, then each feature's domain and data layers.
2. Cubit tests, feature by feature (catalog → cart → home → checkout → orders/profile/auth).
3. design_system widget tests.
4. Feature page widget tests (same feature order).
5. App-level tests in `apps/pharmmed/test/`.

After each group, run `flutter test` and `flutter analyze` in every package you touched, then fix all failures and analyzer issues before moving on. Tick progress in a new `## Testing` section at the bottom of `apps/pharmmed/PHASES.md`.

## Done when

- Every row of the Step 0 test plan has a passing test, or is marked "skipped" with a reason.
- `flutter test` passes in **every** package and in `apps/pharmmed`.
- `flutter analyze` reports zero issues everywhere you touched.
- Optional: `flutter test --coverage` for the feature packages, with domain + cubit coverage above ~80%.

## Final report (keep it short)

```
## Testing: done

### Tests per package
- <package>: <N unit / N cubit / N widget> — all passing

### Bugs found and fixed
- <file> — <what was wrong> (or "none")

### Refactors for testability
- <file> — <change> (or "none")

### Skipped / not worth testing
- <item> — <reason>

### Commands run
- flutter test: <results per package>
- flutter analyze: <result>
```

## Constraints

- Do not modify `pharmaadmin` or `pharmabtob`.
- No golden tests and no `integration_test` package for now.
- Tests must not hit the network or rely on real timers.
- Don't add test packages to `dependencies`, only to `dev_dependencies`.
