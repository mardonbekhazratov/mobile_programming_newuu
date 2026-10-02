class DatabaseException implements Exception {
    final String message;
    DatabaseException(this.message);
    @override
    String toString() => "DatabaseException: $message";
}

final List<String> log = [];

String queryDatabase(String sql){
    throw DatabaseException("connection lost while running '$sql'");
}

String loadUser(int id){
    try{
        return queryDatabase("SELECT * FROM users WHERE id = $id");
    } on DatabaseException catch(e){
        // Do the local work (logging, cleanup)...
        log.add("loadUser($id) failed: ${e.message}");
        // ...then pass the SAME exception and original stack trace up.
        rethrow;
    }
}

// For comparison: `throw e` throws the same object but starts a NEW
// stack trace here, so the place where the error really happened is lost.
String loadUserLosingTrace(int id){
    try{
        return queryDatabase("SELECT * FROM users WHERE id = $id");
    } on DatabaseException catch(e){
        throw e;
    }
}

String firstFrame(StackTrace st) => st.toString().split("\n").first;

void main(){
    try{
        loadUser(7);
    } on DatabaseException catch(e, st){
        print("main caught: $e");
        print("rethrow keeps:  ${firstFrame(st)}");
    }

    try{
        loadUserLosingTrace(7);
    } on DatabaseException catch(_, st){
        print("throw e shows:  ${firstFrame(st)}");
    }
    print("log: $log");
}
