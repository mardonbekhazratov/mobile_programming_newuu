/// Base class for anything that can be described as text.
class Describable {
    /// Returns a short human readable description.
    String describe() => "Describable object";
}

/// A student record.
class Student extends Describable {
    /// Full name of the student.
    final String name;

    /// Student ID number.
    final String id;

    /// Creates a student with [name] and [id].
    Student(this.name, this.id);

    /// Returns `"name (id)"`.
    ///
    /// `@override` tells the analyzer that this method replaces
    /// [Describable.describe]. If the parent method is renamed or removed
    /// the analyzer reports an error instead of silently creating a new method.
    @override
    String describe() => "$name ($id)";

    /// Prints the student to the console.
    ///
    /// `@deprecated` marks this method as outdated: callers get a warning.
    /// Use [describe] instead, it returns the text so it can be reused.
    @deprecated
    void printInfo() => print(describe());

    /// Formats the student as a table row.
    ///
    /// `@Deprecated(...)` does the same as `@deprecated` but also shows
    /// a message telling what to use instead.
    @Deprecated("Use describe() instead. Will be removed in v2.0")
    String toRow() => "$name | $id";

    /// Uses [describe] so `print(student)` shows readable text.
    @override
    String toString() => describe();
}

void main(){
    Student s = Student("Alice", "U2400123");
    print(s.describe());
    print(s);

    // Both calls below still work. When they are used from another
    // file (library), `dart analyze` shows a deprecation warning for them.
    s.printInfo();
    print(s.toRow());
}
