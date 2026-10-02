class Vehicle {
    final String brand;
    final int year;

    Vehicle(this.brand, {this.year = 2026});

    void start() => print("$brand ($year) starting...");
}

class ElectricCar extends Vehicle {
    final int batteryCapacity;

    // `super.brand` and `super.year` forward the arguments straight to
    // Vehicle's constructor, same as `: super(brand, year: year)`.
    ElectricCar(super.brand, this.batteryCapacity, {super.year});

    @override
    void start(){
        super.start();
        print("Battery: $batteryCapacity kWh");
    }
}

void main(){
    ElectricCar("Tesla", 75).start();
    ElectricCar("BYD", 82, year: 2024).start();
}
