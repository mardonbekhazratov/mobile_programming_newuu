// A small Flutter-like state management setup written in plain Dart.

typedef VoidCallback = void Function();

// Like Flutter's ChangeNotifier: keeps listeners and notifies them.
mixin ChangeNotifier {
    final List<VoidCallback> _listeners = [];

    void addListener(VoidCallback listener) => _listeners.add(listener);
    void removeListener(VoidCallback listener) => _listeners.remove(listener);

    void notifyListeners(){
        for(VoidCallback l in List.of(_listeners)){
            l();
        }
    }
}

// Reusable loading flag for any store.
mixin LoadingState on ChangeNotifier {
    bool _isLoading = false;
    bool get isLoading => _isLoading;

    Future<T> runWithLoading<T>(Future<T> Function() task) async {
        _isLoading = true;
        notifyListeners();
        try{
            return await task();
        } finally {
            _isLoading = false;
            notifyListeners();
        }
    }
}

// Reusable error message for any store.
mixin ErrorState on ChangeNotifier {
    String? _error;
    String? get error => _error;

    void setError(String? message){
        if(_error == message) return;
        _error = message;
        notifyListeners();
    }
}

// Reusable undo history for any store.
mixin UndoHistory<T> on ChangeNotifier {
    final List<T> _history = [];

    T get currentState;
    void restoreState(T state);

    void saveSnapshot() => _history.add(currentState);

    void undo(){
        if(_history.isEmpty) return;
        restoreState(_history.removeLast());
        notifyListeners();
    }
}

// The store only contains business logic. Everything else comes from mixins.
class CartStore with ChangeNotifier, LoadingState, ErrorState, UndoHistory<List<String>> {
    List<String> _items = [];
    List<String> get items => List.unmodifiable(_items);

    @override
    List<String> get currentState => List.of(_items);

    @override
    void restoreState(List<String> state) => _items = state;

    void add(String item){
        saveSnapshot();
        _items = [..._items, item];
        notifyListeners();
    }

    Future<void> checkout() async {
        bool ok = await runWithLoading(() async {
            await Future.delayed(const Duration(milliseconds: 300));
            if(_items.isEmpty) return false;
            _items = [];
            return true;
        });
        setError(ok ? null : "Cart is empty");
    }
}

// Like a StatelessWidget that rebuilds when the store changes.
class CartView {
    final CartStore store;
    int _builds = 0;

    CartView(this.store){
        store.addListener(build);
        build();
    }

    void build(){
        _builds++;
        String state = store.isLoading
            ? "Loading..."
            : store.error != null
                ? "Error: ${store.error}"
                : "Items: ${store.items}";
        print("build #$_builds -> $state");
    }

    void dispose() => store.removeListener(build);
}

Future<void> main() async {
    CartStore store = CartStore();
    CartView view = CartView(store);

    store.add("Laptop");
    store.add("Mouse");
    store.undo();
    await store.checkout();
    await store.checkout();

    view.dispose();
    store.add("Keyboard");
    print("View disposed, no rebuild for 'Keyboard'. Items: ${store.items}");
}
