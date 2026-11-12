# Lab 9 - Notes

## Part 1 - Shared code

1. **Why is `CartLine` immutable with `copyWith`?**
   Riverpod, Cubit and Bloc only notify when the new state is different from the old one
   (`==`, which is identity for a class without `==`). If `qty` were mutated in place, the
   state would still be the same object, so nothing would rebuild. Only **setState** would still
   "work", because it rebuilds after the closure whatever the closure did. That is the trap: the
   code works by accident, and breaks as soon as it is moved to another style, put behind a
   `select`/`buildWhen`, or kept in an undo history (the old states would change too, because
   they share the same mutated objects).
2. **Why does `CartBody` take callbacks?**
   So it knows nothing about state management. The same widget is used by all four pages, and
   only the page decides where the data comes from and what a tap does.

## Part 2 - setState

- **T3 - why not store `total`?** Every method that changes `lines` or `coupon` would also
  have to update `total`. Forget one (for example `changeQty` or undo) and the total no longer
  matches the lines. A getter is computed from the real data, so it cannot be out of date.
- **T4 - without `if (!mounted) return;`**: if the page is popped during the 1.5 s await, the
  `State` is already disposed. `setState` then throws `setState() called after dispose()`, and
  `context` can no longer be used to find the `ScaffoldMessenger`.
- **T6**: almost all of the test is finding widgets (chip label, `TextField`, *Apply* button,
  the total text) and pumping frames. The cart logic is not called directly at all.

1. **How would a second page (order history) read the cart?** It can't: the cart is a private
   field of `_SetStateCartPageState` and dies with the page. The state would have to be lifted
   above both pages (for example into the app root or an `InheritedWidget`) and passed down
   with constructor arguments and callbacks, which is building a small state-management library
   by hand.
2. **Where does `_history` live?** In the page's `State` object, next to `_state`. Hot reload
   keeps `State` objects, so the history survives. Hot restart creates the app again, so the
   history (and the cart) is lost. Popping the page also loses it.

## Part 3 - Riverpod

- **T2 - does `state = state.copyWith(coupon: code)` notify when the code is the same?**
  Without `==`, yes: `copyWith` always returns a new object and the default `==` is identity.
  Riverpod 3 compares the old and new state with `==`. Checked with a listener while applying
  `SAVE10` twice: **2** notifications without `==`/`hashCode` on `CartState`, **1** with them.
- **T3**: log from a widget test (tap Keyboard, apply an invalid coupon, tap +):

  ```
  setState                                    Riverpod
  SummaryCard build: total 0.00               SummaryCard build: total 0.00
  -- tap Keyboard                             -- tap Keyboard
  SummaryCard build: total 49.00              SummaryCard build: total 49.00
  -- type and apply invalid coupon            -- type and apply invalid coupon
  SummaryCard build: total 49.00              (no rebuild)
  -- + on Keyboard                            -- + on Keyboard
  SummaryCard build: total 98.00              SummaryCard build: total 98.00
  ```

  Typing alone rebuilds neither version, because the text lives in the `TextEditingController`,
  not in the cart state. The summary selects `s.summary`, a record of
  `(items, subtotal, discount, total)`. Records compare by value, so the card rebuilds only when
  one of the values it shows changes, and it does not need a `ref.read` in `build`.
- **T4 - why no `mounted` check?** The notifier lives in the `ProviderContainer`, not in the
  page, and `cartProvider` is not `autoDispose`. It is still alive after the await even if the
  page was popped. The SnackBar/banner is shown from the page's `ref.listen`, which is removed
  when the page unmounts, so no dead `context` is used. (With `autoDispose` the notifier could
  be disposed during the await, and Riverpod 3 would need `if (!ref.mounted) return;`.)
- **T5**: `canUndoProvider` must `watch(cartProvider)`. `_history` is a plain field that
  Riverpod cannot see, but it only changes together with the cart state, so recomputing on
  every cart change is enough. With `cartProvider.autoDispose`, popping the page removes the
  last listener and the provider is disposed. The notifier, with its `_history`, is thrown away,
  and coming back creates a new notifier with an empty cart and no history. I kept it
  non-`autoDispose` (needed for the T4 answer above).

1. **`ref.read` vs `ref.watch`**
   - `ref.read(cartProvider.notifier)` in the page's `build`: only method handles are needed,
     and they never change.
   - `ref.read(checkoutApiProvider)` in `checkout()`: a one-time lookup inside a method.
   - `ref.read(cartProvider)` in the `ref.listen` callback: the current value inside a
     callback, with no subscription.
   - `ref.watch(cartProvider)` in the page: it displays lines, coupon error and status, so it
     must rebuild.
   - `ref.watch(cartProvider.select((s) => s.summary))` in `_Summary`: it displays the summary,
     so it rebuilds only when the summary changes.
   - (Also: the page watches `canUndoProvider`, which watches `cartProvider`.)
2. **Why does the summary rebuild less often than in setState?** With setState every change
   rebuilds the whole page and creates a new `SummaryCard`. In Riverpod `_Summary` is a `const`
   widget with its own `select` subscription. When the page rebuilds, Flutter reuses the same
   const instance and skips it, and the `select` only fires when the summary values change.
