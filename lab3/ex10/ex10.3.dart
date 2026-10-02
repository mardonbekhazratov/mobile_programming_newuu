class Animal {
    void speak() => print("...");
}

class Dog extends Animal {
    @override
    void speak() => print("Woof");
    void fetch() => print("Dog fetches the ball");
}

class Cat extends Animal {
    @override
    void speak() => print("Meow");
    void climb() => print("Cat climbs the tree");
}

void describe(Object value){
    if(value is int){
        print("int, doubled: ${value * 2}");
    } else if(value is String){
        print("String of length ${value.length}");
    } else if(value is List){
        print("List with ${value.length} items");
    } else {
        print("Something else: ${value.runtimeType}");
    }
}

void main(){
    // `is` checks the runtime type and promotes the variable.
    for(Object v in [42, "Dart", [1, 2, 3], 3.14]){
        describe(v);
    }

    List<Animal> animals = [Dog(), Cat()];
    for(Animal a in animals){
        a.speak();
        if(a is Dog) a.fetch();
        if(a is! Dog) print("not a dog: ${a.runtimeType}");
    }

    // `as` casts explicitly. It works when the object really is that type...
    Animal pet = animals[1];
    (pet as Cat).climb();

    // ...and throws a TypeError when it is not.
    try{
        Animal other = animals[0];
        (other as Cat).climb();
    } on TypeError catch(e){
        print("Cast failed: $e");
    }
}
