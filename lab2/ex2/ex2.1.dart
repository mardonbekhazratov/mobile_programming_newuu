void main () {
    var mutableName = 'Alice';
    final String birthCity = 'Tashkent';
    const double pi = 3.14159;
    late String lazyDescription ;
    lazyDescription = 'Initialized later!';
    print ('$mutableName born in $birthCity. Math constant: $pi. Status: $lazyDescription ');
}
