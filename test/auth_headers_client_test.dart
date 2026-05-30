import 'package:endelea/data/sync/auth_headers_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('adds the headers to every request', () async {
    late http.Request seen;
    final client = AuthHeadersClient(
      {'Authorization': 'Bearer token'},
      MockClient((request) async {
        seen = request;
        return http.Response('ok', 200);
      }),
    );

    await client.get(Uri.parse('https://example.com/files'));

    expect(seen.headers['Authorization'], 'Bearer token');
  });
}
