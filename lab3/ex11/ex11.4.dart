import "dart:async";

Future<void> main() async {
    Completer<void> done = Completer();
    late StreamSubscription<int> subscription;

    Stream<int> ticks = Stream.periodic(const Duration(milliseconds: 500), (i) => i + 1);

    subscription = ticks.listen((tick){
        print("tick $tick at ${DateTime.now().toIso8601String().substring(11, 23)}");
        if(tick == 5){
            subscription.cancel();
            print("Cancelled after 5 ticks");
            done.complete();
        }
    });

    await done.future;
}
