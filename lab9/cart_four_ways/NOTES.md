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
