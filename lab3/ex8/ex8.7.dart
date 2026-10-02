// Immutable configuration objects. Each level adds its own fields
// and passes the rest up with super parameters.
class ServiceConfig {
    final String name;
    final String version;
    final bool debug;

    const ServiceConfig({required this.name, required this.version, this.debug = false});
}

class HttpConfig extends ServiceConfig {
    final String host;
    final int port;
    final bool useTls;

    const HttpConfig({
        required super.name,
        required super.version,
        super.debug,
        this.host = "localhost",
        this.port = 80,
        this.useTls = false,
    });
}

class ApiConfig extends HttpConfig {
    final String basePath;
    final int rateLimitPerMinute;

    const ApiConfig({
        required super.name,
        required super.version,
        super.debug,
        super.host,
        super.port,
        super.useTls,
        this.basePath = "/api",
        this.rateLimitPerMinute = 60,
    });
}

// The service hierarchy mirrors the config hierarchy. The generic
// parameter keeps `config` correctly typed at every level.
abstract class Service<C extends ServiceConfig> {
    final C config;
    const Service(this.config);

    String describe() => "${config.name} v${config.version}${config.debug ? " [debug]" : ""}";
}

class HttpService<C extends HttpConfig> extends Service<C> {
    const HttpService(super.config);

    String get url => "${config.useTls ? "https" : "http"}://${config.host}:${config.port}";

    @override
    String describe() => "${super.describe()} at $url";
}

class ApiService extends HttpService<ApiConfig> {
    const ApiService(super.config);

    String endpoint(String path) => "$url${config.basePath}/$path";

    @override
    String describe() => "${super.describe()}, limit ${config.rateLimitPerMinute}/min";
}

void main(){
    const api = ApiService(ApiConfig(
        name: "StudentAPI",
        version: "2.1.0",
        host: "api.newuu.uz",
        port: 443,
        useTls: true,
        rateLimitPerMinute: 120,
    ));

    const web = HttpService(HttpConfig(name: "StaticSite", version: "1.0.0", debug: true));

    print(web.describe());
    print(api.describe());
    print(api.endpoint("students/42"));

    // Everything is const, so the whole object tree is deeply immutable.
    List<Service> services = [web, api];
    for(Service s in services){
        print("${s.runtimeType} -> ${s.config.name}");
    }
}
