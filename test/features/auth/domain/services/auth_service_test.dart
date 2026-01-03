import 'package:flutter_test/flutter_test.dart';
import 'package:keynest/features/auth/domain/services/auth_service.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
  });

  group('AuthService Tests', () {
    test('Initial state should be unauthenticated', () {
      expect(authService.isAuthenticated, isFalse);
      expect(authService.jwt, isNull);
      expect(authService.currentEmail, isNull);
    });

    test('register should authenticate user and set mock JWT', () async {
      const email = 'test@example.com';
      const password = 'password123';

      await authService.register(email, password);

      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentEmail, equals(email));
      expect(authService.jwt, startsWith('mock-jwt-'));
    });

    test('login should authenticate user and set mock JWT', () async {
      const email = 'user@example.com';
      const password = 'password456';

      await authService.login(email, password);

      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentEmail, equals(email));
      expect(authService.jwt, startsWith('mock-jwt-'));
    });

    test('logout should clear auth state', () async {
      await authService.login('test@example.com', 'password');
      expect(authService.isAuthenticated, isTrue);

      authService.logout();

      expect(authService.isAuthenticated, isFalse);
      expect(authService.jwt, isNull);
      expect(authService.currentEmail, isNull);
    });

    test('isAuthenticated should reflect current state', () async {
      expect(authService.isAuthenticated, isFalse);
      
      await authService.login('test@example.com', 'password');
      expect(authService.isAuthenticated, isTrue);
      
      authService.logout();
      expect(authService.isAuthenticated, isFalse);
    });
  });
}
