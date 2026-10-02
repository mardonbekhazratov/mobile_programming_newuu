import "dart:math";

sealed class Shape {}

class Circle extends Shape {
    final double radius;
    Circle(this.radius);
}

class Square extends Shape {
    final double side;
    Square(this.side);
}

class Triangle extends Shape {
    final double base, height;
    Triangle(this.base, this.height);
}

// No default case: the compiler knows every subclass of the sealed class.
// Adding a new Shape subclass makes this switch a compile error until
// the new case is handled.
double area(Shape shape) => switch(shape){
    Circle(radius: var r) => pi * r * r,
    Square(side: var s) => s * s,
    Triangle(base: var b, height: var h) => b * h / 2,
};

sealed class NetworkResult<T> {}

class Success<T> extends NetworkResult<T> {
    final T data;
    Success(this.data);
}

class Failure<T> extends NetworkResult<T> {
    final String message;
    final int code;
    Failure(this.message, this.code);
}

class Loading<T> extends NetworkResult<T> {}

String render(NetworkResult<String> result) => switch(result){
    Loading() => "Loading...",
    Success(:var data) => "Data: $data",
    Failure(code: 404) => "Not found",
    Failure(:var message, :var code) when code >= 500 => "Server error: $message",
    Failure(:var message) => "Error: $message",
};

void main(){
    List<Shape> shapes = [Circle(1), Square(3), Triangle(4, 5)];
    for(Shape s in shapes){
        print("${s.runtimeType}: ${area(s).toStringAsFixed(2)}");
    }

    List<NetworkResult<String>> results = [
        Loading(),
        Success("Hello"),
        Failure("Missing page", 404),
        Failure("Database down", 503),
        Failure("Bad request", 400),
    ];
    for(NetworkResult<String> r in results){
        print(render(r));
    }
}
