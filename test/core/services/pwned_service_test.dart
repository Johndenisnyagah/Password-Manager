import 'package:flutter_test/flutter_test.dart';
import 'package:keynest/core/services/pwned_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class MockClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request)? onSend;
  
  MockClient({this.onSend});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await (onSend?.call(request) ?? Future.value(http.Response('', 200)));
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  group('PwnedService Tests', () {
    test('checkPassword should return 0 for empty password', () async {
      // Use mock client to avoid any network calls
      final mockClient = MockClient(onSend: (request) async {
        return http.Response('', 200);
      });
      final service = PwnedService(client: mockClient);
      final count = await service.checkPassword('');
      expect(count, 0);
    });

    test('checkPassword should return breach count when found', () async {
      const password = 'password123';
      // SHA-1 of 'password123' is CBFDAC6008F9CAB4083784CBD1874F76618D2A97
      // Prefix: CBFDA, Suffix: C6008F9CAB4083784CBD1874F76618D2A97
      
      final mockClient = MockClient(onSend: (request) async {
        // Verify request URL contains correct prefix
        if (!request.url.toString().contains('CBFDA')) {
          throw Exception('Unexpected URL: ${request.url}');
        }
        return http.Response('C6008F9CAB4083784CBD1874F76618D2A97:1234567\nOTHER:10', 200);
      });

      final service = PwnedService(client: mockClient);
      final count = await service.checkPassword(password);
      
      expect(count, 1234567);
    });

    test('checkPassword should return 0 if not in list', () async {
      const password = 'secure-and-private-password-999';
      
      final mockClient = MockClient(onSend: (request) async {
        return http.Response('SOMEOTHERHASH:10\nANOTHER:20', 200);
      });

      final service = PwnedService(client: mockClient);
      final count = await service.checkPassword(password);
      
      expect(count, 0);
    });

    test('checkPassword should return 0 on API error', () async {
      final mockClient = MockClient(onSend: (request) async {
        return http.Response('Error', 500);
      });

      final service = PwnedService(client: mockClient);
      final count = await service.checkPassword('password');
      
      expect(count, 0);
    });

    test('checkPassword should handle network exception', () async {
      final mockClient = MockClient(onSend: (request) async {
        throw Exception('Network failed');
      });

      final service = PwnedService(client: mockClient);
      final count = await service.checkPassword('password');
      
      expect(count, 0);
    });
  });
}
