enum Setting<T extends Object> {
    volume<int>("volume", 50),
    darkMode<bool>("dark_mode", false),
    language<String>("language", "en"),
    fontScale<double>("font_scale", 1.0);

    final String key;
    final T defaultValue;

    const Setting(this.key, this.defaultValue);

    Type get valueType => T;

    bool accepts(Object? value) => value is T;

    // Returns the stored value if it has the right type, otherwise the default.
    T read(Map<String, Object?> storage){
        Object? value = storage[key];
        return value is T ? value : defaultValue;
    }

    static Setting? fromKey(String key){
        for(Setting s in values){
            if(s.key == key) return s;
        }
        return null;
    }

    static Map<String, Object> defaults() =>
        {for(Setting s in values) s.key: s.defaultValue};
}

void main(){
    print("Defaults: ${Setting.defaults()}");

    Map<String, Object?> saved = {"volume": 80, "dark_mode": "yes", "language": "uz"};

    int volume = Setting.volume.read(saved);
    bool dark = Setting.darkMode.read(saved);
    String lang = Setting.language.read(saved);
    double scale = Setting.fontScale.read(saved);
    print("volume=$volume, darkMode=$dark, language=$lang, fontScale=$scale");

    Setting? s = Setting.fromKey("dark_mode");
    print("${s?.name} stores ${s?.valueType}, accepts 'yes'? ${s?.accepts("yes")}");
}
