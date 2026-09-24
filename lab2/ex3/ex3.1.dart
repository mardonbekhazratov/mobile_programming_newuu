void main () {
    int score = 85;
    String grade = switch (score) {
        >= 90 => 'A',
        >= 80 => 'B',
        >= 70 => 'C',
        _ => 'F'
    };
    print('Grade achieved: $grade');
}
