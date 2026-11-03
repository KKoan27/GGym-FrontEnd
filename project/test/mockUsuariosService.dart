import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class MockUsuariosService {
  MockUsuariosService({required this.statusCode, this.responseBody = ''});

  final int statusCode;
  final String responseBody;
  http.Request? lastRequest;
  final List<http.Request> requests = [];

  MockClient createClient() {
    return MockClient((request) async {
      lastRequest = request;
      requests.add(request);
      return http.Response(responseBody, statusCode);
    });
  }
}
