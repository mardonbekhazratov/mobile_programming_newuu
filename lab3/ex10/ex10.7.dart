class AppAction {
    final String type;
    final Map<String, Object> payload;
    AppAction(this.type, [this.payload = const {}]);

    @override
    String toString() => "$type $payload";
}

abstract class ActionHandler {
    String get name;
    bool canHandle(AppAction action);
    String handle(AppAction action);
}

class LoggerPlugin extends ActionHandler {
    final List<String> history = [];

    @override
    String get name => "logger";

    @override
    bool canHandle(AppAction action) => true;

    @override
    String handle(AppAction action){
        history.add(action.type);
        return "logged '${action.type}' (#${history.length})";
    }
}

class MathPlugin extends ActionHandler {
    @override
    String get name => "math";

    @override
    bool canHandle(AppAction action) => action.type == "add" || action.type == "multiply";

    @override
    String handle(AppAction action){
        num a = action.payload["a"] as num;
        num b = action.payload["b"] as num;
        num result = action.type == "add" ? a + b : a * b;
        return "${action.type}($a, $b) = $result";
    }
}

class GreetingPlugin extends ActionHandler {
    @override
    String get name => "greeting";

    @override
    bool canHandle(AppAction action) => action.type.startsWith("greet");

    @override
    String handle(AppAction action) => "Hello, ${action.payload["name"] ?? "stranger"}!";
}

class PluginRegistry {
    // Plugins that can be created by name, e.g. from a config file.
    static final Map<String, ActionHandler Function()> available = {
        "logger": LoggerPlugin.new,
        "math": MathPlugin.new,
        "greeting": GreetingPlugin.new,
    };

    final List<ActionHandler> _handlers = [];

    void load(String pluginName){
        ActionHandler Function()? create = available[pluginName];
        if(create == null){
            print("! unknown plugin '$pluginName'");
            return;
        }
        _handlers.add(create());
        print("+ loaded plugin '$pluginName'");
    }

    void unload(String pluginName){
        _handlers.removeWhere((h) => h.name == pluginName);
        print("- unloaded plugin '$pluginName'");
    }

    // The registry never checks concrete types: every handler is called
    // through the same ActionHandler interface.
    void dispatch(AppAction action){
        print("dispatch: $action");
        List<ActionHandler> matching = _handlers.where((h) => h.canHandle(action)).toList();
        if(matching.isEmpty){
            print("    no handler for '${action.type}'");
        }
        for(ActionHandler h in matching){
            print("    [${h.name}] ${h.handle(action)}");
        }
    }
}

void main(){
    PluginRegistry registry = PluginRegistry();
    for(String name in ["logger", "math", "weather"]){
        registry.load(name);
    }

    registry.dispatch(AppAction("add", {"a": 2, "b": 3}));
    registry.dispatch(AppAction("greet", {"name": "Alice"}));

    registry.load("greeting");
    registry.dispatch(AppAction("greet", {"name": "Alice"}));

    registry.unload("logger");
    registry.dispatch(AppAction("multiply", {"a": 4, "b": 2.5}));
}
