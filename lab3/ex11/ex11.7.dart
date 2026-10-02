import "dart:async";

class ChatMessage {
    final String author;
    final String text;
    final DateTime time = DateTime.now();
    ChatMessage(this.author, this.text);
}

class ChatRoom {
    late final StreamController<ChatMessage> _controller =
        StreamController<ChatMessage>.broadcast(
            onListen: () => print("  (room is live)"),
            onCancel: () => print("  (no more subscribers)"),
        );

    // Many subscribers can listen to a broadcast stream at the same time.
    Stream<ChatMessage> get messages => _controller.stream;

    StreamSubscription<ChatMessage> subscribe(String name, void Function(ChatMessage) onMessage){
        print("  + $name joined");
        return messages.listen(onMessage, onDone: () => print("  $name: room closed"));
    }

    void send(String author, String text){
        if(_controller.isClosed) throw StateError("Room is closed");
        _controller.add(ChatMessage(author, text));
    }

    Future<void> close() => _controller.close();
}

Future<void> pause() => Future.delayed(const Duration(milliseconds: 100));

Future<void> main() async {
    ChatRoom room = ChatRoom();

    // Nobody listens yet: broadcast streams drop these events.
    room.send("system", "Is anyone here?");

    StreamSubscription<ChatMessage> ui = room.subscribe("UI", (m){
        print("  [UI] ${m.author}: ${m.text}");
    });

    int count = 0;
    room.subscribe("Counter", (m){
        count++;
        print("  [Counter] $count message(s)");
    });

    // A subscriber that only cares about mentions.
    room.messages
        .where((m) => m.text.contains("@bob"))
        .listen((m) => print("  [Notify bob] ${m.author} mentioned you"));

    room.send("alice", "Hello everyone!");
    await pause();
    room.send("alice", "@bob are you coming to the lab?");
    await pause();

    await ui.cancel();
    print("  - UI left");
    room.send("bob", "Yes, on my way");
    await pause();

    await room.close();
}
