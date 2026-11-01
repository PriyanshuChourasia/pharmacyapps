# PharmMed — demo notes

Everything runs on local demo data. There are no network calls and no real payments.

## Try it

| What | How |
|---|---|
| Coupons | `PHARMA10`: 10% off the selling total, capped at ₹100. `FIRST50`: ₹50 off when the selling total is ₹300 or more. Codes are trimmed and case-insensitive. |
| Delivery fee | Free when the payable amount (after coupon, before delivery) is **above ₹499**; otherwise ₹40. |
| Login | Any non-empty phone/email plus any password. Emails become the display name (`rahul@x.com` → "Rahul"); phone numbers become "Customer". "Create account" uses the entered name. The session lasts for the app run only. |
| Addresses | Two demo addresses (Rahul Sharma, Mumbai 400053 and Pune 411001), Mumbai selected. New addresses are kept in memory. |
| Prescription | An Rx item (e.g. **Glycomet 500**) blocks "Place order" until a prescription is "uploaded". The upload is a mock: it marks the prescription attached and nothing more. |
| Payment | Cash on Delivery succeeds immediately. UPI (demo) waits 1.5 s, then succeeds. |
| Per-item limit | 10 of any item. Going past it shows a snackbar. |

## What persists

- **Cart + applied coupon:** stored in `shared_preferences` (`cart_v1`, `cart_coupon_v1`), so they survive a relaunch.
- **Orders, addresses, login:** kept in memory. They reset when the app restarts.

## Assumptions

- Search, product detail, category lists, checkout, login, add-address and order success are **top-level routes** that cover the bottom nav. This keeps "back" returning to the tab you came from. `RoutePaths` was updated to match (`/search`, `/product/:id`, `/category/:categoryId`, `/order-success?id=`). Order detail (`/orders/:id`) and saved addresses (`/profile/addresses`) stay inside their tabs.
- The cart's applied coupon lives in `CartRepository` (`couponCode` / `setCouponCode`), so checkout bills exactly what the cart showed. If the cart drops below a coupon's minimum, the coupon stays stored but stops applying, and the cart shows why.
- The cart badge counts units, not lines (Dolo 650 × 2 shows "2").
- Orders are always "Placed". The timeline shows Packed / Shipped / Delivered as pending.
- The deals countdown runs to local midnight.
- The Home "Deals of the day" row has Hero animations turned off, because those products can also appear in other Home sections.

## Swapping in a real API

Features only depend on interfaces from `core` / `shared_models`. To go live:

1. **Catalog:** write a new datasource or repository that `implements CatalogRepository` (e.g. `ApiCatalogRepository`), and register it in `registerCatalogModule` instead of `DemoCatalogRepository`.
2. **Orders / addresses:** implement `OrdersRepository` / `AddressRepository` and swap the registrations in `registerCheckoutModule`.
3. **Payments:** implement `PaymentGateway` (e.g. Razorpay) and swap `DemoPaymentGateway`.
4. **Auth:** implement `AuthSession` and swap `DemoAuthSession` in `apps/dawaidukaan/lib/app/di/injector.dart`.

No page or cubit needs to change. Only the DI registrations do.
