class Vehicle {
    final String brand;
    Vehicle(this.brand);
    void start() => print("$brand starting...");
}

class ElectricCar extends Vehicle {
    final int batteryCapacity;
    ElectricCar(String brand, this.batteryCapacity) : super(brand);

    @override
    void start(){
        super.start();
        print("Battery level: $batteryCapacity kWh");
    }
}

void main(){
    Vehicle v = Vehicle("Chevrolet");
    v.start();

    Vehicle e = ElectricCar("BYD", 82);
    e.start();
}
