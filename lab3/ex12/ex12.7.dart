import "dart:async";
import "dart:convert";
import "dart:io";

// ---------- Domain failures ----------

sealed class Failure {
    final String message;
    const Failure(this.message);
}

class NoConnectionFailure extends Failure {
    const NoConnectionFailure() : super("No internet connection");
}

class TimeoutFailure extends Failure {
    const TimeoutFailure() : super("The server took too long to respond");
}

class ServerFailure extends Failure {
    final int statusCode;
    const ServerFailure(this.statusCode, String message) : super(message);
}

class ParsingFailure extends Failure {
    const ParsingFailure() : super("Received invalid data");
}

class UnknownFailure extends Failure {
    final Object error;
    const UnknownFailure(this.error) : super("Something went wrong");
}

// ---------- Result type ----------

sealed class Result<T> {
    const Result();
}

class Ok<T> extends Result<T> {
    final T value;
    const Ok(this.value);
}

class Err<T> extends Result<T> {
    final Failure failure;
    const Err(this.failure);
}

// ---------- Raw transport (fake network) ----------

class HttpStatusException implements Exception {
    final int statusCode;
    final String body;
    HttpStatusException(this.statusCode, this.body);
}

class FakeHttpTransport {
    Future<String> get(String path) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return switch(path){
            "/users/1" => '{"id": 1, "name": "Alice"}',
            "/users/2" => '{"id": 2, "name": ',
            "/offline" => throw const SocketException("Network is unreachable"),
            "/slow" => await Future.delayed(const Duration(seconds: 2), () => "{}"),
            "/broken" => throw HttpStatusException(500, "Internal Server Error"),
            "/missing" => throw HttpStatusException(404, "Not Found"),
            _ => throw const HttpException("Unexpected redirect loop"),
        };
    }
}

// ---------- API client wrapper ----------

class ApiClient {
    final FakeHttpTransport _transport;
    final Duration timeout;

    ApiClient(this._transport, {this.timeout = const Duration(seconds: 1)});

    // Every raw exception is turned into a Failure here, so the rest of
    // the app never sees SocketException, TimeoutException, etc.
    Future<Result<Map<String, dynamic>>> getJson(String path) async {
        try{
            String body = await _transport.get(path).timeout(timeout);
            return Ok(jsonDecode(body) as Map<String, dynamic>);
        } on SocketException {
            return const Err(NoConnectionFailure());
        } on TimeoutException {
            return const Err(TimeoutFailure());
        } on HttpStatusException catch(e){
            return Err(ServerFailure(e.statusCode, e.body));
        } on FormatException {
            return const Err(ParsingFailure());
        } catch(e){
            return Err(UnknownFailure(e));
        }
    }
}

class User {
    final int id;
    final String name;
    User(this.id, this.name);
}

class UserRepository {
    final ApiClient _api;
    UserRepository(this._api);

    Future<Result<User>> fetchUser(String path) async {
        Result<Map<String, dynamic>> result = await _api.getJson(path);
        return switch(result){
            Ok(:var value) => Ok(User(value["id"] as int, value["name"] as String)),
            Err(:var failure) => Err(failure),
        };
    }
}

// ---------- UI layer: only knows about Failures ----------

String showFailure(Failure f) => switch(f){
    NoConnectionFailure() => "Check your connection and try again.",
    TimeoutFailure() => "Server is slow, please retry later.",
    ServerFailure(statusCode: 404) => "Requested item does not exist.",
    ServerFailure(:var statusCode, :var message) => "Server error $statusCode: $message",
    ParsingFailure() => "We got a broken response.",
    UnknownFailure(:var error) => "Unexpected: $error",
};

Future<void> main() async {
    UserRepository repo = UserRepository(ApiClient(FakeHttpTransport()));
    List<String> paths = ["/users/1", "/users/2", "/offline", "/slow", "/broken", "/missing", "/weird"];

    for(String path in paths){
        Result<User> result = await repo.fetchUser(path);
        String text = switch(result){
            Ok(:var value) => "OK: user #${value.id} ${value.name}",
            Err(:var failure) => "${failure.runtimeType}: ${showFailure(failure)}",
        };
        print("${path.padRight(10)} -> $text");
    }
}
