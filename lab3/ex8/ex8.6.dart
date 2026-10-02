import "ex8.6_lib.dart";

// Each commented line is a compile-time error:

// class SavingsAccount extends BankAccount {}
//   -> The class 'BankAccount' can't be extended outside of its library
//      because it's a final class.

// class FakeAccount implements BankAccount {}
//   -> The class 'BankAccount' can't be implemented outside of its library
//      because it's a final class.

// class Toy implements Vehicle {}
//   -> The class 'Vehicle' can't be implemented outside of its library
//      because it's a base class.

// class Bus extends Vehicle { Bus() : super("Isuzu"); }
//   -> 'Bus' must be 'base', 'final' or 'sealed' because the supertype
//      'Vehicle' is 'base'.

// Allowed: extending a base class with a final subclass.
// Since Car is final, nobody else can extend it and override start() again.
final class Car extends Vehicle {
    Car(super.brand);

    @override
    void start(){
        super.start();
        print("$brand: ready to drive");
    }
}

void main(){
    BankAccount account = BankAccount();
    account.deposit(100);
    print("Balance: ${account.balance}");

    Car("Malibu").start();
}
