void loadConfig(String path) => parseConfig(path, "port=abc");

void parseConfig(String path, String content){
    String value = content.split("=")[1];
    int.parse(value);
}

void main(){
    try{
        loadConfig("app.conf");
    } catch(e, stackTrace){
        print("Error: $e");
        print("Stack trace:");
        print(stackTrace);
    }

    // The current stack can be captured at any point without an error.
    print("Current stack:");
    print(StackTrace.current.toString().split("\n").first);

    // Throw an error with a stack trace that was captured earlier.
    StackTrace saved = StackTrace.current;
    try{
        Error.throwWithStackTrace(StateError("delayed failure"), saved);
    } catch(e, st){
        print("$e, thrown with saved trace: ${identical(st, saved)}");
    }
}
