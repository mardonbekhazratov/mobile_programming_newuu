// Library used by ex8.6.dart.
// Class modifiers only restrict code in OTHER libraries (files),
// so the classes live here and are used from ex8.6.dart.

// `final`: can't be extended or implemented outside this file,
// so none of its methods can ever be overridden there.
final class BankAccount {
    double _balance = 0;

    double get balance => _balance;

    void deposit(double amount){
        if(amount <= 0) throw ArgumentError("Amount must be positive");
        _balance += amount;
    }
}

// `base`: can be extended outside this file, but not implemented.
// Every subclass inherits the real implementation of start(),
// and the subclass itself must be base, final or sealed.
base class Vehicle {
    final String brand;
    Vehicle(this.brand);

    void start() => print("$brand: engine check passed, starting...");
}
