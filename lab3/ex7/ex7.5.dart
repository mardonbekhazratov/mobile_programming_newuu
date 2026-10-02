enum Role { student, teacher, admin }

// byName() throws ArgumentError for unknown names, so wrap it.
Role? parseRole(String? raw){
    if(raw == null) return null;
    try{
        return Role.values.byName(raw.trim().toLowerCase());
    } on ArgumentError{
        return null;
    }
}

Role parseRoleOr(String? raw, Role fallback) => parseRole(raw) ?? fallback;

void main(){
    List<String?> inputs = ["student", " Teacher ", "ADMIN", "guest", "", null];
    for(String? raw in inputs){
        print("'$raw' -> ${parseRole(raw)}");
    }

    print("with fallback: ${parseRoleOr("hacker", Role.student)}");

    // What happens without the safety wrapper:
    try{
        Role.values.byName("guest");
    } on ArgumentError catch(e){
        print("byName error: ${e.message}");
    }
}
