class ExamResult {
    final String student;
    final int score;
    final String grade;

    // The initializer list runs BEFORE the fields are assigned and before
    // the constructor body, so bad values never reach the object.
    ExamResult(String student, int score)
        : student = student.trim().isEmpty
              ? throw ArgumentError("Student name must not be empty")
              : student.trim(),
          score = (score < 0 || score > 100)
              ? throw RangeError.range(score, 0, 100, "score")
              : score,
          grade = score >= 90 ? "A" : score >= 80 ? "B" : score >= 70 ? "C" : "F";
}

class Rectangle {
    final double width, height;

    // assert() in an initializer list only runs in debug mode
    // (dart run --enable-asserts ex6.3.dart).
    Rectangle(this.width, this.height)
        : assert(width > 0, "width must be positive"),
          assert(height > 0, "height must be positive");
}

void main(){
    ExamResult r = ExamResult("  Alice ", 87);
    print("${r.student}: ${r.score} -> ${r.grade}");

    try{
        ExamResult("Bob", 120);
    } catch(e){
        print("Error: $e");
    }

    try{
        ExamResult("", 50);
    } catch(e){
        print("Error: $e");
    }

    Rectangle rect = Rectangle(2, 3);
    print("Rectangle ${rect.width}x${rect.height}");

    try{
        Rectangle(-1, 3);
        print("No error: asserts are off (run with --enable-asserts)");
    } on AssertionError catch(e){
        print("AssertionError: ${e.message}");
    }
}
