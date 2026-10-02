import "dart:math";

/*
 * Solves the quadratic equation a*x^2 + b*x + c = 0
 * using the quadratic formula:
 *
 *          -b +- sqrt(b^2 - 4ac)
 *     x = -----------------------
 *                  2a
 *
 * The discriminant D = b^2 - 4ac tells how many real roots exist:
 *     D > 0  -> two different real roots
 *     D == 0 -> one repeated real root
 *     D < 0  -> no real roots (the roots are complex)
 */
List<double> solveQuadratic(double a, double b, double c){
    // Discriminant decides how many real roots there are.
    double d = b * b - 4 * a * c;

    // Square root of a negative number is not real -> no roots.
    if(d < 0) return [];

    // Both roots collapse into one when D is zero: x = -b / 2a.
    if(d == 0) return [-b / (2 * a)];

    // sqrt(D) is shared by both roots, so compute it only once.
    double sqrtD = sqrt(d);

    // One root uses +sqrt(D), the other one uses -sqrt(D).
    return [(-b + sqrtD) / (2 * a), (-b - sqrtD) / (2 * a)];
}

void main(){
    // x^2 - 3x + 2 = (x - 1)(x - 2) -> roots 2 and 1
    print(solveQuadratic(1, -3, 2));

    // x^2 + 2x + 1 = (x + 1)^2 -> single root -1
    print(solveQuadratic(1, 2, 1));

    // x^2 + 1 = 0 -> D = -4, no real roots
    print(solveQuadratic(1, 0, 1));
}
