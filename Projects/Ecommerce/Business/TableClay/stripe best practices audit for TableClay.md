---
created: 2026-02-18
description: Stripe integration best practices audit for TableClay ecommerce store
source: internal
type: reference
parent: "[[moc - TableClay]]"
---

  Task 2: Stripe Best Practices Audit

  Issues Found
  ┌──────────────────────┬──────────┬─────────────────────────┬─────────────────────────┐
  │        Issue         │ Severity │         Current         │       Recommended       │
  ├──────────────────────┼──────────┼─────────────────────────┼─────────────────────────┤
  │ confirmCardPayment() │ HIGH     │ Using deprecated method │ Use confirmPayment()    │
  ├──────────────────────┼──────────┼─────────────────────────┼─────────────────────────┤
  │ API Version          │ MEDIUM   │ Not pinned              │ Pin to specific version │
  ├──────────────────────┼──────────┼─────────────────────────┼─────────────────────────┤
  │ CardElement          │ LOW      │ Legacy element          │ Consider PaymentElement │
  └──────────────────────┴──────────┴─────────────────────────┴─────────────────────────┘
  Already Following Best Practices ✅

  - Webhook signature verification (HMAC)
  - Idempotency keys on all operations
  - SetupIntents for saved payments
  - No deprecated APIs (Charges, Sources, Tokens)
  - Proper error handling with retry logic
  - Auto-capture configured correctly

  ---
  PaymentElement vs CardElement Comparison
  Feature: Payment methods
  CardElement (Current): Card only
  PaymentElement: Card + Link + Google Pay + Apple Pay + 40+ methods
  ────────────────────────────────────────
  Feature: Address collection
  CardElement (Current): Manual
  PaymentElement: Built-in option
  ────────────────────────────────────────
  Feature: 3D Secure
  CardElement (Current): Manual handling
  PaymentElement: Automatic
  ────────────────────────────────────────
  Feature: Future payment methods
  CardElement (Current): Requires code changes
  PaymentElement: Automatic updates
  ────────────────────────────────────────
  Feature: Internationalization
  CardElement (Current): Basic
  PaymentElement: Full support
  ────────────────────────────────────────
  Feature: Customization
  CardElement (Current): Limited
  PaymentElement: Theme system
  Migration Effort

  Moderate complexity - about 4-5 files:
  1. stripe-wrapper.tsx - Update Elements options
  2. payment-form/index.tsx - Replace CardElement with PaymentElement
  3. payment-button/index.tsx - Use confirmPayment() instead of confirmCardPayment()
  4. checkout-footer/index.tsx - Same change

