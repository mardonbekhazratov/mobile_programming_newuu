// `interface class`: other libraries can implement it but not extend it.
interface class DBConnector {
    void connect(String url){}
    List<Map<String, Object>> query(String sql) => [];
    void close(){}
}

class MySQLConnector implements DBConnector {
    bool _connected = false;
    final Map<String, List<Map<String, Object>>> _tables = {
        "students": [
            {"id": 1, "name": "Alice"},
            {"id": 2, "name": "Bob"},
        ],
    };

    @override
    void connect(String url){
        _connected = true;
        print("MySQL: connected to $url");
    }

    @override
    List<Map<String, Object>> query(String sql){
        if(!_connected) throw StateError("Not connected");
        print("MySQL: $sql");
        String table = sql.split(" ").last;
        return _tables[table] ?? [];
    }

    @override
    void close(){
        _connected = false;
        print("MySQL: connection closed");
    }
}

// Code depends only on the interface, so the database can be swapped.
void printStudents(DBConnector db){
    for(Map<String, Object> row in db.query("SELECT * FROM students")){
        print("  ${row["id"]}: ${row["name"]}");
    }
}

void main(){
    DBConnector db = MySQLConnector();
    db.connect("mysql://localhost:3306/university");
    printStudents(db);
    db.close();
}
