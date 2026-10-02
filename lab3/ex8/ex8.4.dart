import "dart:math";

abstract class Shape {
    final String name;
    Shape(this.name);

    double get area;
    double get perimeter;

    void describe(){
        print("$name: area=${area.toStringAsFixed(2)}, perimeter=${perimeter.toStringAsFixed(2)}");
    }
}

class Polygon extends Shape {
    final List<double> sides;

    Polygon(super.name, this.sides){
        if(sides.length < 3) throw ArgumentError("A polygon needs at least 3 sides");
    }

    int get sideCount => sides.length;

    @override
    double get perimeter => sides.reduce((a, b) => a + b);

    // A general polygon needs coordinates to find the area,
    // so subclasses with a known shape override it.
    @override
    double get area => throw UnimplementedError("Area unknown for a generic polygon");
}

class Triangle extends Polygon {
    Triangle(double a, double b, double c) : super("Triangle", [a, b, c]){
        if(a + b <= c || a + c <= b || b + c <= a){
            throw ArgumentError("Sides $a, $b, $c can't form a triangle");
        }
    }

    // Heron's formula: sqrt(s(s-a)(s-b)(s-c)), s = half of the perimeter
    @override
    double get area {
        double s = perimeter / 2;
        return sqrt(s * (s - sides[0]) * (s - sides[1]) * (s - sides[2]));
    }

    bool get isRight {
        List<double> x = [...sides]..sort();
        return (x[0] * x[0] + x[1] * x[1] - x[2] * x[2]).abs() < 1e-9;
    }
}

void main(){
    Triangle t = Triangle(3, 4, 5);
    t.describe();
    print("sides: ${t.sideCount}, right triangle: ${t.isRight}");

    // A Triangle can be used wherever a Polygon or a Shape is expected.
    Polygon asPolygon = t;
    Shape asShape = t;
    print("as Polygon: ${asPolygon.sideCount} sides, as Shape: ${asShape.name}");

    try{
        Triangle(1, 2, 10);
    } on ArgumentError catch(e){
        print("Error: ${e.message}");
    }
}
