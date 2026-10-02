Future<String> fetchWeather() async {
    await Future.delayed(const Duration(seconds: 1));
    return "Tashkent: 24 C, sunny";
}

Future<String> fetchNews() async {
    await Future.delayed(const Duration(seconds: 2));
    return "NewUU opens a new lab";
}

Future<String> fetchExchangeRate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return "1 USD = 12 650 UZS";
}

Future<void> main() async {
    Stopwatch sw = Stopwatch()..start();

    // All three start at the same time, so the total time is the
    // slowest one (~2 s), not the sum (~4.5 s).
    List<String> results = await Future.wait([
        fetchWeather(),
        fetchNews(),
        fetchExchangeRate(),
    ]);

    print("Dashboard (loaded in ${sw.elapsedMilliseconds} ms):");
    for(String r in results){
        print(" - $r");
    }
}
