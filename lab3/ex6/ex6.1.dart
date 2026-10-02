class Point {
    final double x, y;
    const Point(this.x, this.y);
    Point.origin() : x = 0, y = 0;
    factory Point.fromJson(Map<String, double> json) =>
        Point(json["x"] ?? 0, json["y"] ?? 0);

    @override
    String toString() => "Point($x, $y)";
}

void main(){
    Point a = Point(3, 4);
    const Point b = Point(1, 2);
    Point c = Point.origin();
    Point d = Point.fromJson({"x": 5.5});
    print("$a $b $c $d");
}
