// `mixin class` can be used both with `implements` and with `with`.
mixin class Logger {
    final List<String> logs = [];

    void log(String message){
        logs.add(message);
        print("[$runtimeType] $message");
    }
}

// implements: only the INTERFACE is taken. Every member (even the
// `logs` field) must be written again in this class.
class FileService implements Logger {
    @override
    final List<String> logs = [];

    @override
    void log(String message){
        logs.add(message);
        print("[FileService -> file.txt] $message");
    }

    void save() => log("file saved");
}

// with: the IMPLEMENTATION is copied in. Nothing to rewrite.
class NetworkService with Logger {
    void fetch() => log("data fetched");
}

void main(){
    FileService f = FileService();
    NetworkService n = NetworkService();

    f.save();
    n.fetch();

    // Both are Loggers, so they can be used polymorphically.
    for(Logger l in [f, n]){
        print("${l.runtimeType} as Logger: ${l.logs.length} log(s)");
    }

    print("""
implements                      | with
--------------------------------|-------------------------------
copies only method signatures   | copies fields + method bodies
must override every member      | gets members for free
any number of interfaces        | any number of mixins
no code reuse, only a contract  | code reuse, linearized order""");
}
