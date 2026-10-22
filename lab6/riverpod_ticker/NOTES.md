# Lab 6 - Notes

## Riverpod 3 differences from the lab sheet

The project uses `flutter_riverpod` 3.4.3, and a few lines of the sheet needed changes:

- `riverpod_test` could not be added: every version depends on `riverpod ^2`, which
  conflicts with `flutter_riverpod` 3. None of the tests use it, so only `mocktail` was added.
- `StateProvider` now lives in `package:flutter_riverpod/legacy.dart`, and `Override`
  (used by the test `harness`) in `package:flutter_riverpod/misc.dart`.
- Riverpod 3 **retries failed providers automatically** (200 ms, 400 ms, ... up to 10 times).
  While retrying, the state is `AsyncLoading(retrying: true)` instead of `AsyncError`,
  so the error arms, the banner and the error tests could never trigger.
  `tickerProvider` sets `retry: (_, _) => null` so the error surfaces and the user retries
  manually. Without it, 3 of the 6 tests fail.
- An `autoDispose` provider that is only `container.read` is disposed right after the read,
  so `read(tickerProvider.future)` fails with "disposed during loading state". The first
  provider test keeps it alive with `container.listen`, like the second test already does.

## Part 2

Checkpoint log (`ref.listen` in `TickerPage`):

```
AsyncData<List<Tick>>(value: [Instance of 'Tick', Instance of 'Tick', Instance of 'Tick'])
AsyncData<List<Tick>>(value: [Instance of 'Tick', Instance of 'Tick', Instance of 'Tick'])
...
```

`ref.listen` only fires on changes, so it does not print the initial state. With
`container.listen(tickerProvider, ..., fireImmediately: true)` the full sequence is:

```
AsyncLoading<List<Tick>>()  hasValue=false isLoading=true
AsyncData<List<Tick>>(...)  hasValue=true  isLoading=false   (every 500 ms)
```

1. **Why is the feed behind its own `Provider`?**
   So it can be replaced without touching `tickerProvider`: tests use
   `tickFeedProvider.overrideWithValue(TickFeed(...))` and the demo builds it with a different
   `failAfter`. It also keeps one `TickFeed` instance (and its last prices) alive when
   `tickerProvider` is invalidated or retried, so a retry continues from the last prices.
2. **What does `autoDispose` do when the user navigates away mid-stream?**
   When the last listener goes away, the provider is disposed: the stream subscription is
   cancelled (the `async*` loop stops) and the state is thrown away. Coming back starts again
   from `AsyncLoading` with the 800 ms delay.
3. **What does `tickerProvider` hold during the 800 ms delay?**
   `AsyncLoading<List<Tick>>()`, with `hasValue == false` (no previous value or error yet).

## Part 3

**3.3** With the `AsyncLoading()` arm commented out, `flutter analyze` reports a compile error:

```
error • The type 'AsyncValue<List<Tick>>' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'AsyncLoading<List<Tick>>()'. Try adding a wildcard pattern or cases that match 'AsyncLoading<List<Tick>>()' • lib/ticker_page.dart:15:13 • non_exhaustive_switch_expression
```

**3.4** Checked with `TickFeed(symbols: const [])` ("No symbols subscribed") and
`TickFeed(symbols: const ['BTC'])` (a single centered `TickRow`).
The arms must come first because a switch takes the first arm that matches, and
`AsyncData(:final value)` matches every `AsyncData`, empty and single lists included.
Below it they would never run; the analyzer flags them as `unreachable_switch_case`.

All three states are reachable: spinner on cold start, rows after 800 ms, and with
`TickFeed(failAfter: 5)` the error after 5 ticks.

## Part 4

**4.3 refresh vs invalidate.** Measured with a widget test (pull down, then sample every 200 ms):

| `onRefresh`                                 | rows during reload | pull spinner                           |
| ------------------------------------------- | ------------------ | -------------------------------------- |
| `() => ref.refresh(tickerProvider.future)`  | visible            | stays until new prices arrive (~800 ms) |
| `() async => ref.invalidate(tickerProvider)` | visible            | starts closing at once                  |

Both keep the previous rows: both move the provider to `AsyncData(isLoading: true)` with the
old value, which the `AsyncValue(:final value?, isLoading: true)` arm draws under a progress
bar. The difference is the indicator. `ref.refresh(x)` is "invalidate, then read `x`", and
reading `tickerProvider.future` returns a `Future<List<Tick>>` that completes with the next
emission, so `RefreshIndicator` can await it. `invalidate` returns `void`, so `onRefresh`
finishes immediately. The app keeps `ref.refresh(tickerProvider.future)`.
The `RefreshIndicator` wraps the whole `switch`: if it wrapped only the data list, it would be
unmounted as soon as the state switches to the refresh arm.

**4.4 reconnect vs first load.** States measured after each action:

| action                         | state                                   |
| ------------------------------ | --------------------------------------- |
| cold start                     | `AsyncLoading`, no value                |
| `invalidate` / `refresh`       | `AsyncData(isLoading: true)`, isRefreshing |
| `failAfterProvider` changed    | `AsyncLoading` with value, isReloading  |
| Retry after an error           | `AsyncError(isLoading: true)` with value, isRefreshing |

The full-screen spinner only matches `AsyncLoading()` with no value, so it never appears
after prices were shown. But with the sheet's order, a retry is still an `AsyncError`, so the
banner and its Retry button stayed up during the reconnect with no feedback. I moved the
`AsyncValue(:final value?, isLoading: true)` arm to the top: a retry now shows the thin
progress bar over the last prices until new data arrives.

`isRefreshing` means the provider was forced to re-run (`ref.refresh` / `ref.invalidate`)
while nothing it depends on changed, whereas `isReloading` means it re-ran because a
watched dependency changed (here `failAfterProvider`).

Checkpoint (checked in a widget test): with `failAfter = 5` the banner shows over dimmed
rows, Retry brings back live rows, and the full-screen spinner only shows on cold start.

## Checkpoint questions

1. `AsyncData`, `AsyncLoading` and `AsyncError`. A switch expression that misses one is a
   compile error, `non_exhaustive_switch_expression` (full text in 3.3).
2. `AsyncError.value` is non-null when the provider emitted data before failing: Riverpod
   copies the last value into the error (feed ticks 5 times, then throws). It is null when the
   error comes before any value, e.g. `Stream.error(...)` straight away, `failAfter: 0`,
   or the first load after the provider was disposed.
3. - `ref.refresh(provider)` invalidates and reads right away, returning the new
     `AsyncValue` (here `AsyncData(isLoading: true)`); you cannot await it.
   - `ref.refresh(provider.future)` does the same but returns the `Future` of the next value,
     so it can be awaited (e.g. by `RefreshIndicator`).
   - `ref.invalidate(provider)` only marks the provider dirty and returns `void`; it rebuilds
     the next time it is read or listened to.

   All three keep the previous value while loading.
4. A refresh does not change the subtype: during `ref.refresh` / `ref.invalidate` the state
   is `AsyncData(value, isLoading: true)`, which `AsyncData(:final value)` also matches.
   Placed below it, the refresh arm would never run for refreshes, so no progress bar.
   The analyzer does not warn here, because the arm still matches `AsyncLoading` and `AsyncError`.
5. A switch expression is checked for exhaustiveness and can match on content and flags
   (`value: []`, `value?`, `isLoading: true`) in a priority order that you choose.
   `.when` is still handy for a short inline widget where its defaults
   (`skipLoadingOnRefresh: true`) are exactly what you want, for example
   `ref.watch(balanceProvider).when(data: (b) => Text('$b'), error: ..., loading: ...)`.

## Part 5

`flutter test` passes 6 tests, including the error-after-data widget test, which uses a
`StreamController` to push `sample` and then an error.
