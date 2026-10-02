abstract class Employee {
    final String name;
    Employee(this.name);

    // Abstract members: every subclass MUST implement them.
    String get role;
    double monthlySalary();

    // Concrete method: shared by all subclasses, uses the abstract members.
    void printPayslip(){
        print("${name.padRight(8)} | ${role.padRight(10)} | \$${monthlySalary().toStringAsFixed(2)}");
    }
}

class FullTimeEmployee extends Employee {
    final double yearlySalary;
    FullTimeEmployee(super.name, this.yearlySalary);

    @override
    String get role => "Full-time";

    @override
    double monthlySalary() => yearlySalary / 12;
}

class Contractor extends Employee {
    final double hourlyRate;
    final int hoursWorked;
    Contractor(super.name, this.hourlyRate, this.hoursWorked);

    @override
    String get role => "Contractor";

    @override
    double monthlySalary() => hourlyRate * hoursWorked;
}

void main(){
    // Employee("x");  // error: abstract classes can't be instantiated
    List<Employee> staff = [
        FullTimeEmployee("Alice", 60000),
        Contractor("Bob", 25, 120),
    ];
    for(Employee e in staff){
        e.printPayslip();
    }
}
