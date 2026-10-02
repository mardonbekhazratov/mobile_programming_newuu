Stream<int> sensorReadings() async* {
    List<int> values = [20, 20, 21, 21, 21, 35, 22, 22, -5, 23, 23, 40, 24];
    for(int v in values){
        await Future.delayed(const Duration(milliseconds: 50));
        yield v;
    }
}

Future<void> main() async {
    print("Raw:      ${await sensorReadings().toList()}");

    // distinct() drops a value only if it equals the PREVIOUS one.
    print("Distinct: ${await sensorReadings().distinct().toList()}");

    Stream<String> pipeline = sensorReadings()
        .distinct()
        .where((t) => t >= 0 && t <= 30)         // drop sensor glitches
        .map((t) => "${(t * 9 / 5 + 32).toStringAsFixed(1)} F");

    await for(String reading in pipeline){
        print("Reading: $reading");
    }
}
