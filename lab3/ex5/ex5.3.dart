/// Static helpers for validating user input.
///
/// The class only has static members, so it can not be instantiated.
class Validator {
    Validator._();

    static final RegExp _emailPattern = RegExp(r"^[\w.+-]+@[\w-]+\.[\w.]+$");

    /// Checks whether [email] is a valid email address.
    ///
    /// Parameters:
    /// - [email]: the address to check, for example `student@newuu.uz`.
    ///
    /// Returns `true` if [email] looks like `name@domain.tld`,
    /// otherwise `false`.
    ///
    /// Throws an [ArgumentError] if [email] is empty.
    static bool isValidEmail(String email){
        if(email.isEmpty){
            throw ArgumentError.value(email, "email", "must not be empty");
        }
        return _emailPattern.hasMatch(email);
    }

    /// Validates that [age] is inside the inclusive range [min]..[max].
    ///
    /// Parameters:
    /// - [age]: the value to validate.
    /// - [min]: the smallest allowed age, `0` by default.
    /// - [max]: the largest allowed age, `150` by default.
    ///
    /// Returns the same [age], so the call can be used inline.
    ///
    /// Throws a [RangeError] if [age] is outside of the range.
    static int validateAge(int age, {int min = 0, int max = 150}){
        RangeError.checkValueInInterval(age, min, max, "age");
        return age;
    }

    /// Checks if [password] is strong enough.
    ///
    /// Parameters:
    /// - [password]: the password to check.
    /// - [minLength]: required number of characters, `8` by default.
    ///
    /// Returns a [List] of problems found. The list is empty when
    /// the password is good.
    ///
    /// Throws a [FormatException] if [password] contains whitespace.
    static List<String> checkPassword(String password, {int minLength = 8}){
        if(password.contains(RegExp(r"\s"))){
            throw FormatException("Password must not contain spaces", password);
        }
        List<String> problems = [];
        if(password.length < minLength) problems.add("shorter than $minLength characters");
        if(!password.contains(RegExp(r"\d"))) problems.add("has no digits");
        return problems;
    }
}

void main(){
    print(Validator.isValidEmail("student@newuu.uz"));
    print(Validator.isValidEmail("not-an-email"));
    print(Validator.validateAge(20));
    print(Validator.checkPassword("qwerty"));
    print(Validator.checkPassword("secret123"));

    try{
        Validator.validateAge(200);
    } on RangeError catch(e){
        print(e);
    }
    try{
        Validator.checkPassword("my password1");
    } on FormatException catch(e){
        print("FormatException: ${e.message}");
    }
}
