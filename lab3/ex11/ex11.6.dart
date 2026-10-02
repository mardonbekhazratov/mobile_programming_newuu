// Raw lines coming from a "file" or "network". Some are broken.
Stream<String> rawLines() async* {
    List<String> lines = ["10", "20", "abc", "30", "-1", "40"];
    for(String line in lines){
        await Future.delayed(const Duration(milliseconds: 50));
        yield line;
    }
}

int parsePositive(String s){
    int value = int.parse(s);   // throws FormatException for "abc"
    if(value < 0) throw RangeError("negative value: $value");
    return value;
}

Future<void> main() async {
    int sum = 0;

    // When map() throws, the error is sent down the stream as an error
    // event and the stream keeps going with the next value.
    Stream<int> numbers = rawLines()
        .map(parsePositive)
        .handleError(
            (Object e) => print("  skipped bad line: '${(e as FormatException).source}'"),
            test: (e) => e is FormatException,
        )
        .handleError((Object e){
            print("  skipped out of range: $e");
        }, test: (e) => e is RangeError);

    await for(int n in numbers){
        sum += n;
        print("  added $n, sum = $sum");
    }
    print("Total: $sum");

    // Errors not caught by handleError reach listen's onError.
    print("Without handleError:");
    rawLines().map(int.parse).listen(
        (n) => print("  value $n"),
        onError: (Object e) => print("  onError: ${e.runtimeType}"),
        onDone: () => print("  done"),
    );
}
