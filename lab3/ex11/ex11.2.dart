final Map<int, Map<String, Object>> _usersTable = {
    1: {"id": 1, "name": "Alice", "major": "Software Engineering"},
    2: {"id": 2, "name": "Bob", "major": "Computer Science"},
};

// Simulates a slow database query.
Future<Map<String, Object>> findUserById(int id) async {
    await Future.delayed(const Duration(seconds: 2));
    Map<String, Object>? row = _usersTable[id];
    if(row == null) throw StateError("User $id not found");
    return row;
}

Future<void> main() async {
    Stopwatch sw = Stopwatch()..start();

    print("Looking up user 1...");
    Map<String, Object> user = await findUserById(1);
    print("Found: ${user["name"]} (${user["major"]}) after ${sw.elapsedMilliseconds} ms");

    print("Looking up user 99...");
    try{
        await findUserById(99);
    } on StateError catch(e){
        print("Error: ${e.message} after ${sw.elapsedMilliseconds} ms");
    }
}
