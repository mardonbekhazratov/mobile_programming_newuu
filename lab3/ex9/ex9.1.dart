abstract class Printable { void printData(); }

mixin TimestampLogger on Printable {
    void logWithTime(){
        print("${DateTime.now()}:");
        printData();
    }
}

// Note: the listing in the PDF, `class Report implements Printable with
// TimestampLogger`, does not compile:
//   1. `with` must come before `implements`;
//   2. a mixin declared `on Printable` can only be applied when the
//      superclass is already a Printable (Object is not).
// So Report extends Printable and then mixes in TimestampLogger.
class Report extends Printable with TimestampLogger {
    @override
    void printData() => print("Q3 Financial Summary");
}

// Implicit interface: every class is also an interface. Invoice only
// implements Printable, so it must provide printData() itself and does
// not get logWithTime().
class Invoice implements Printable {
    @override
    void printData() => print("Invoice #42: \$1200");
}

void main(){
    Report().logWithTime();

    List<Printable> documents = [Report(), Invoice()];
    for(Printable d in documents){
        d.printData();
    }
}
