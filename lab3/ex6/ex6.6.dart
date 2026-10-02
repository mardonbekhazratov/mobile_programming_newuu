class UserDto {
    final int id;
    final String name;
    final String email;
    final List<String> roles;

    const UserDto({
        required this.id,
        required this.name,
        required this.email,
        this.roles = const [],
    });

    factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json["id"] as int,
        name: json["name"] as String,
        email: json["email"] as String,
        roles: List.unmodifiable(json["roles"] as List? ?? []),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "roles": roles,
    };

    // Objects can't be changed, so "changing" means creating a new copy.
    UserDto copyWith({int? id, String? name, String? email, List<String>? roles}) =>
        UserDto(
            id: id ?? this.id,
            name: name ?? this.name,
            email: email ?? this.email,
            roles: roles ?? this.roles,
        );

    @override
    bool operator ==(Object other) =>
        other is UserDto &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.roles.join(",") == roles.join(",");

    @override
    int get hashCode => Object.hash(id, name, email, Object.hashAll(roles));

    @override
    String toString() => "UserDto(id: $id, name: $name, email: $email, roles: $roles)";
}

void main(){
    // const objects with the same values are the very same instance.
    const a = UserDto(id: 1, name: "Alice", email: "alice@newuu.uz");
    const b = UserDto(id: 1, name: "Alice", email: "alice@newuu.uz");
    print("identical: ${identical(a, b)}");

    UserDto fromJson = UserDto.fromJson({
        "id": 2,
        "name": "Bob",
        "email": "bob@newuu.uz",
        "roles": ["student"],
    });
    print(fromJson);

    UserDto renamed = fromJson.copyWith(name: "Robert");
    print(renamed);
    print("original unchanged: ${fromJson.name}");
    print("equal by value: ${fromJson == fromJson.copyWith()}");

    try{
        fromJson.roles.add("admin");
    } on UnsupportedError catch(e){
        print("Can't modify roles: ${e.message}");
    }
    print(renamed.toJson());
}
