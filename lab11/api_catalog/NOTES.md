# Lab 11 – REST API client with Cubit and Bloc

## Part 1 – Setup

- `dart run bin/peek.dart` prints `200`, `Essence Mascara Lash Princess`, `_Map<String, dynamic>`.
- **Field types in `product.json`:**
  - number: `price` (`9.99`). `weight` (`4`) and `stock` (`99`) are numbers too.
  - list of strings: `tags` (`["beauty", "mascara"]`), and also `images`.
  - nested object: `dimensions` (`{"width": 15.14, "height": 13.08, "depth": 22.99}`), and also `meta`.
  - list of objects: `reviews`.
- **`/products/0`:** status `404`, body `{"message":"Product with id '0' not found"}`.

## Part 2 – Models

- **T6, missing `tags`:** they become an empty list (`?? const []` in `Product.fromJson`), so the
  UI never has to handle `null`. A missing `brand` is `null`. Tested in `test/models_test.dart`.
- **`json['price'] as double` when the server sends `10`:** `jsonDecode` turns `10` into an `int`,
  and the cast fails with `type 'int' is not a subtype of type 'double' in type cast`. This happens
  at **run time**. The compiler can't catch it because the map's values are `dynamic`. (On the web
  `int` and `double` are both JS numbers, so it only breaks on mobile/desktop.)
- **Saved file vs live request:** the test always gets the same data, so a failure points to the
  parsing code and not to the network or the server. It runs offline and in CI, and it's fast.
  DummyJSON can also change values like `rating` between runs, but the fixture stays the same.

## Part 4 – Cubit

- **`?delay=3000`, leaving the screen without `isClosed`:** `BlocProvider` closes the Cubit when the
  screen is popped. Three seconds later the response arrives and `emit` runs on a closed Cubit,
  which throws `StateError: Cannot emit new states after calling close`. That error is unhandled
  (red in the console, a crash report in production). With the check, the late result is dropped.
- **Why `isA<…>()`:** `ProductsLoaded` doesn't override `==`, so two instances with the same
  products are still two different objects, and `ProductsLoaded([...])` would never equal the
  emitted state. To compare by value, override `==` and `hashCode` (with `listEquals` for the list,
  and `==` on `Product` too) or extend `Equatable` from the `equatable` package.

## Part 5 – Bloc

- **T15, the cancel:** I temporarily added `'delay': '3000'` to the search query, submitted `phone`
  and 0.5 s later `laptop`. States seen: `SearchLoading` at 0 s, then `SearchResults` at about 4 s
  with *Apple MacBook Pro 14 Inch Space Grey, Asus Zenbook Pro Dual Screen Laptop, …*. The phone
  results never appeared. The delay was then removed.

## Checkpoint questions

1. **From response to row:**
   - `product_api.dart`, `_get`: `http.Response` → `response.body` (a `String`) → `jsonDecode` → `Map<String, dynamic>`.
   - `models/product_page.dart`, `ProductPage.fromJson`: `json['products']` (a `List<dynamic>`) → each
     `Map<String, dynamic>` → `Product.fromJson` in `models/product.dart`, which calls `Dimensions.fromJson`
     and `Review.fromJson` → `ProductPage`.
   - `cubit/products_cubit.dart`, `load`: `ProductPage` → `ProductsLoaded(List<Product>, total)`, emitted.
   - `screens/products_screen.dart`: `BlocBuilder` switches on `ProductsLoaded` → `ProductTile(Product)`.
   - `widgets/product_tile.dart`: `Product` → `Image.network`, two `Text`s in a `ListTile`.
2. **Errors in `getProducts`** (all end as `ApiException` → `ProductsError` with a Retry button):
   - no network or the connection drops (`http.ClientException`): *"No internet connection…"*;
   - no answer within 10 s (`TimeoutException`): *"The server is taking too long…"*;
   - a status other than 200, e.g. 404/500: *"Server answered 500"*;
   - a body that isn't JSON (`FormatException`): *"The server sent data the app could not read."*

   Valid JSON with a different shape would throw a `TypeError` inside `fromJson`. That's a bug in
   the model, not a user error. It isn't caught, so the screen would stay on the spinner.
3. **Cubit vs Bloc:** use a Cubit when the UI just calls methods and each call is handled on its
   own. The list is like that: `load()`, `loadMore()`, refresh. Use a Bloc when the input is a
   stream of events whose timing matters and you want to control it (cancel, debounce, drop) with a
   transformer, plus a log of named events. Search is like that: each new query should replace the
   old one, and that's one `restartable()` line.
4. **`restartable()`:** when a new `SearchSubmitted` arrives, it cancels the handler still running
   for the old one. That handler's later `emit`s are ignored, and only the newest query can produce
   results. The default transformer runs handlers concurrently: both requests finish and both emit.
   The user would see phone results flash before laptop results, or, if the old request is slower,
   phone results replace the laptop results and stay there under the query "laptop".
5. **Why widgets never call `http.get` or read a `Map`:**
   - `build` runs many times (rebuilds, rotations, keyboard), so a request inside it would be sent
     again and again. Loading state, errors and cancelling would also have to be repeated in every widget.
   - `Map` keys and types aren't checked by the compiler. A typo or a server change would crash
     somewhere in the UI at run time. With models, it fails in one `fromJson` covered by a test.
   - Widgets that only draw states can be tested and previewed without a network. The API and the
     Cubit/Bloc are tested on their own with a `MockClient`.
