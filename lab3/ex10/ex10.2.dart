import "dart:math";

abstract class Shape {
    double area();
}

class Circle extends Shape {
    final double radius;
    Circle(this.radius);

    @override
    double area() => pi * radius * radius;

    @override
    String toString() => "Circle(r=$radius)";
}

class Rectangle extends Shape {
    final double width, height;
    Rectangle(this.width, this.height);

    @override
    double area() => width * height;

    @override
    String toString() => "Rectangle(${width}x$height)";
}

void main(){
    List<Shape> shapes = [Circle(1), Rectangle(3, 4), Circle(2.5), Rectangle(2, 2)];

    double total = 0;
    for(Shape s in shapes){
        double a = s.area();
        total += a;
        print("$s area = ${a.toStringAsFixed(2)}");
    }
    print("Total area = ${total.toStringAsFixed(2)}");
}
