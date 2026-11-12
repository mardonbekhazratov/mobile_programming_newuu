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

## Part 4 - Cubit

- **T2**: I kept the hand-written `==` from Part 3 instead of adding Equatable. `onChange`
  log while applying `SAVE10` twice. The second emit is dropped and `onChange` is not called:

  ```
  -- SAVE10
  CartCubit CartState(idle) -> CartState(SAVE10, idle, history: 1)
  -- SAVE10 again
  -- add Keyboard
  CartCubit CartState(SAVE10, idle, history: 1) -> CartState(Keyboard×1, SAVE10, idle, history: 2)
  ```

- **T4 - `emit` after `close()`**: it throws
  `Bad state: Cannot emit new states after calling close`. Popping the page mid-checkout
  closes the cubit (`BlocProvider` disposes it), so after the await `checkout()` checks
  `if (isClosed) return;`.
- **T5**: a `bool get canUndo` on the cubit is not part of the state, so `BlocBuilder` never
  hears about it changing. Fix: the history is now a field of `CartState` (`canUndo` is a
  getter on it), and `push`/`pop` are pure helpers in the model. `history` is left out of
  `==`, so an emit that changes nothing is dropped together with its history entry.
- **T6**: the Riverpod test only checks the final state. `blocTest` checks the exact list of
  emitted states, so an extra emit, a missing emit or a wrong order also fails the test.

1. **What would break if `BlocProvider` were inside `CartBody`?** A provider is only visible to
   widgets below it. The page's `BlocBuilder`, `BlocListener` and `context.read` are above
   `CartBody`, so they would throw `ProviderNotFoundException`. `CartBody` would also stop being
   dumb shared UI: the setState and Riverpod pages would create a cubit they never use.
2. **Riverpod equivalents**

   | flutter_bloc | Riverpod |
   |---|---|
   | `BlocProvider` | the provider declaration + `ProviderScope` (a nested scope/override to limit it, `autoDispose` for lifetime) |
   | `BlocBuilder` | `ref.watch` in a `ConsumerWidget` / `Consumer` |
   | `BlocListener` | `ref.listen` |
   | `context.read` | `ref.read` |
   | `buildWhen` | `select` (selects a value to compare instead of a predicate) |

## Part 5 - Bloc

- **T2 - transition log** (`TransitionLogger` in `main.dart`), from the demo flow:

  ```
  CartBloc: CartState(Monitor×3, idle, history: 3) --CartQtyChanged--> CartState(Monitor×4, idle, history: 4)
  CartBloc: CartState(Monitor×3, idle, history: 5) --CartCouponApplied--> CartState(Monitor×3, SAVE10, idle, history: 6)
  CartBloc: CartState(Monitor×3, SAVE10, idle, history: 6) --CartCheckoutRequested--> CartState(Monitor×3, SAVE10, submitting, history: 6)
  CartBloc: CartState(Monitor×3, SAVE10, submitting, history: 6) --CartCheckoutRequested--> CartState(Monitor×3, SAVE10, failure, history: 6)
  CartBloc: CartState(Monitor×3, SAVE10, failure, history: 6) --CartUndone--> CartState(Monitor×3, failure, history: 5)
  ```

  Compared with the Cubit's `onChange` (`current -> next` only), every transition also names
  the **event** that caused it, so each change can be traced to a user action.
- **T3**: the Part 4 card is now `SelectedSummary<B extends StateStreamable<CartState>>` and
  is used as `SelectedSummary<CartCubit>` and `SelectedSummary<CartBloc>`. It still rebuilds
  only when the summary changes.
- **T4 - triple tap with `droppable()`**: the first `CartCheckoutRequested` runs. The next two
  arrive while its handler is still running and are dropped, so there is one `submitting`, one
  API call and one result (the third test checks `submit` is called once). With the Cubit,
  `checkout()` is a plain method, so each tap starts its own API call: three orders. The 2nd
  and 3rd `submitting` emits equal the current state and are dropped, so the Cubit log looks
  clean even though the API was called three times. **`emit.isDone`**: `close()` cancels the
  handler's emitter, and a cancelled emitter ignores `emit`. `isDone` is also true after the
  handler has completed (an `emit` then fails an assert). The check makes the case explicit
  and skips the work.
- **T5 - undoable events** (the `isUndoable` switch in `CartBloc`): `CartProductAdded`,
  `CartProductRemoved`, `CartQtyChanged` and `CartCouponApplied` are user edits, so they are
  undoable. `CartCheckoutRequested` is not: status changes are not edits, and a successful
  order clears the cart and its history. `CartUndone` is not either, because it pops the
  history. The switch is exhaustive, so a new event does not compile until this decision is
  made for it.

1. **When is the event layer worth its boilerplate?** When you need to know or control *which
   kind* of action is happening: logging and analytics by event, undo decisions, and
   per-event concurrency (`droppable`, `restartable`, `debounce`). Clearly better here:
   **checkout**, where one `transformer: droppable()` drops duplicate taps and the log names
   the event. Pure overhead: **the quantity stepper**, a one-line synchronous change that needs
   an event class, a handler and `add(...)` for the same result as a Cubit method.
2. **"Drop duplicate taps" declaratively**: only **Bloc**, with `transformer: droppable()`. In
   the other three it is an imperative guard at the start of `checkout`,
   `if (state.status == CheckoutStatus.submitting) return;` (`_state` in setState), or
   disabling the button while submitting.

## Checkpoint questions

1. **Where state lives / when it dies**
   - setState: in the page's `State` object, and it dies when the page is popped (or on hot
     restart).
   - Riverpod: in the root `ProviderScope`'s `ProviderContainer`, and it lives as long as the
     app (with `autoDispose`, it dies when the last listener goes away).
   - Cubit: in the `CartCubit` created by the page's `BlocProvider`, and it is closed when the
     page is popped.
   - Bloc: in the `CartBloc` created by the page's `BlocProvider`, and it is closed when the
     page is popped.
2. **Single public mutation API**: in Riverpod's `Notifier`, the notifier's methods (only the
   notifier can assign `state`). In Cubit, the cubit's methods (only the cubit can `emit`). In
   Bloc, `add(event)`. **setState has none**: the state is a private field of the `State`, and
   nothing outside can change it.
3. **Mapping**: `ref.watch` ↔ `BlocBuilder` (`BlocSelector`/`select` ↔ `buildWhen`),
   `ref.read` ↔ `context.read`, `ref.listen` ↔ `BlocListener`. setState has no separate
   pieces: the `State` reads its own fields, `setState` rebuilds the whole widget (an
   unfiltered "watch"), and side effects are called directly after the await (no "listen").
4. **Why skip when `new == old`?** Nothing changed, so a rebuild or notification would be
   wasted work (and repeated side effects). For this to work, `CartState` must be
   **immutable** (every change is a new object made with `copyWith`; a state mutated in place
   equals itself, so the change would be lost), and it must have **value equality**: override
   `==` and `hashCode`, comparing `lines` element by element, which needs `==` on `CartLine` too.
5. **Guard after the await in checkout**
   - setState: `mounted`. The `State` can be disposed during the await, and `setState`/`context`
     are then invalid.
   - Riverpod: nothing. The notifier lives in the container, which outlives the page, and the
     side effects are in a `ref.listen` that goes away with the page.
   - Cubit: `isClosed`. The cubit is closed with the page, and `emit` after `close()` throws.
   - Bloc: `emit.isDone`. The emitter belongs to one handler, and it is done when the bloc
     closes or the handler completes.

   They differ because the state holder's lifetime is tied to a different thing each time:
   the widget, the container, the `BlocProvider`, or a single event handler.

## Comparison table

Lines = non-blank lines of the final code in each style's folder (sample + T1-T5). Shared code
is not counted: model 128, widgets 128, checkout API 13.

| Style | Lines T1-T5 | Test lines | Files (lib + test) | Strength | Weakness |
|---|---|---|---|---|---|
| setState | 54 | 16 | 1 + 1 | Fewest concepts: nothing to add, wire or learn | State dies with the page and cannot be shared; can only be tested through widgets |
| Riverpod | 74 | 32 | 2 + 1 | State lives outside the tree; `select` limits rebuilds; tests need no widgets and dependencies are swapped with overrides | Plain fields like `_history` are invisible to Riverpod, so derived providers must watch the right thing; `read`/`watch` are easy to mix up |
| Cubit | 79* | 41 | 2 + 1 | Plain methods, and `blocTest` checks the exact sequence of states | No concurrency control (triple tap = three API calls); anything the UI needs must be in the state |
| Bloc | 109 | 58 | 3 + 1 | Every change is traceable to an event; concurrency is declarative (`droppable`) | Most boilerplate: an event class and a handler for every one-line change |

\* includes `SelectedSummary`, which the Bloc page reuses.
