mixin Flyable {
    int altitude = 0;

    void fly(){
        altitude += 100;
        print("$runtimeType is flying at $altitude m");
    }

    void land(){
        altitude = 0;
        print("$runtimeType landed");
    }
}

class Animal {
    final String name;
    Animal(this.name);
}

class Bird extends Animal with Flyable {
    Bird(super.name);
}

void main(){
    Bird b = Bird("Sparrow");
    print("${b.name}:");
    b.fly();
    b.fly();
    b.land();
}
