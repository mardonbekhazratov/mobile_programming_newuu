class AppConfig {
    // Static fields are initialized lazily, exactly once, the first time
    // they are read. Dart isolates do not share memory, so there is no race
    // between threads: no locks are needed to make this thread-safe.
    static final AppConfig _instance = AppConfig._internal();

    final Map<String, String> _settings = {};

    // Private named constructor: code outside this file can not call it.
    AppConfig._internal(){
        print("AppConfig created");
    }

    // Factory constructor always returns the same instance.
    factory AppConfig() => _instance;

    void set(String key, String value) => _settings[key] = value;
    String? get(String key) => _settings[key];
}

void main(){
    AppConfig a = AppConfig();
    AppConfig b = AppConfig();

    a.set("theme", "dark");
    print("b sees theme = ${b.get("theme")}");
    print("Same object: ${identical(a, b)}");
}
