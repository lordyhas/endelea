import 'package:http/http.dart' as http;

/// HTTP client adding authorization headers to every request.
class AuthHeadersClient extends http.BaseClient {
  AuthHeadersClient(this.headers, [http.Client? inner])
    : _inner = inner ?? http.Client();

  final Map<String, String> headers;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(headers);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
