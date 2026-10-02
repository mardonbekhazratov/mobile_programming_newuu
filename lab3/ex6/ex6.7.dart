class Color {
    final int red, green, blue;
    final double opacity;

    // Primary (master) constructor: the only one that sets the fields.
    Color(this.red, this.green, this.blue, this.opacity){
        for(int c in [red, green, blue]){
            if(c < 0 || c > 255) throw RangeError.range(c, 0, 255, "channel");
        }
        if(opacity < 0 || opacity > 1) throw RangeError("opacity must be 0..1");
    }

    // Redirecting constructors: no body, they just call another constructor.
    Color.rgb(int r, int g, int b) : this(r, g, b, 1.0);
    Color.gray(int level) : this.rgb(level, level, level);
    Color.black() : this.gray(0);
    Color.white() : this.gray(255);
    Color.transparent() : this(0, 0, 0, 0);
    Color.hex(String hex) : this.rgb(
        int.parse(hex.substring(1, 3), radix: 16),
        int.parse(hex.substring(3, 5), radix: 16),
        int.parse(hex.substring(5, 7), radix: 16),
    );

    @override
    String toString() => "Color(r: $red, g: $green, b: $blue, a: $opacity)";
}

void main(){
    print(Color(10, 20, 30, 0.5));
    print(Color.rgb(255, 0, 0));
    print(Color.gray(128));
    print(Color.black());
    print(Color.white());
    print(Color.transparent());
    print(Color.hex("#1E90FF"));

    try{
        Color.gray(300);
    } catch(e){
        print("Error: $e");
    }
}
