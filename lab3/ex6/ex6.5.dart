class Student {
    final String name;
    double _gpa = 0;
    String _email = "";

    Student(this.name, {double gpa = 0, String email = ""}){
        this.gpa = gpa;
        if(email.isNotEmpty) this.email = email;
    }

    double get gpa => _gpa;

    set gpa(double value){
        if(value < 0 || value > 4){
            throw RangeError("GPA must be between 0.0 and 4.0, got $value");
        }
        _gpa = value;
    }

    String get email => _email;

    set email(String value){
        if(!value.contains("@")){
            throw FormatException("Invalid email", value);
        }
        _email = value.toLowerCase();
    }

    // Computed getter, no setter.
    bool get isHonors => _gpa >= 3.5;
}

void main(){
    Student s = Student("Alice", gpa: 3.2, email: "Alice@NewUU.uz");
    print("${s.name}: gpa=${s.gpa}, email=${s.email}, honors=${s.isHonors}");

    s.gpa = 3.8;
    print("New gpa=${s.gpa}, honors=${s.isHonors}");

    try{
        s.gpa = 5;
    } on RangeError catch(e){
        print("Error: ${e.message}");
    }

    try{
        s.email = "wrong-email";
    } on FormatException catch(e){
        print("Error: ${e.message} (${e.source})");
    }
}
