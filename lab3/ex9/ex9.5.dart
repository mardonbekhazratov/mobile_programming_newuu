class Vehicle {
    final String name;
    int speed = 0;

    Vehicle(this.name);

    void accelerate(int delta){
        speed += delta;
        print("$name speed: $speed km/h");
    }
}

// `on Vehicle`: Turbo can only be mixed into Vehicle subclasses,
// so it is allowed to use Vehicle members and call super.
mixin Turbo on Vehicle {
    bool turboOn = false;

    @override
    void accelerate(int delta){
        super.accelerate(turboOn ? delta * 2 : delta);
    }

    void toggleTurbo(){
        turboOn = !turboOn;
        print("$name turbo ${turboOn ? "ON" : "OFF"}");
    }
}

class SportsCar extends Vehicle with Turbo {
    SportsCar(super.name);
}

// class Bicycle with Turbo {}
//   -> error: 'Turbo' can't be mixed onto 'Object' because 'Object'
//      doesn't implement 'Vehicle'.

void main(){
    SportsCar car = SportsCar("Ferrari");
    car.accelerate(40);
    car.toggleTurbo();
    car.accelerate(40);
}
