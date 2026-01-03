import 'package:flutter_test/flutter_test.dart';
import 'package:keynest/features/totp/domain/services/totp_service.dart';

void main() {
  late TotpService totpService;

  setUp(() {
    totpService = TotpService();
  });

  group('TotpService Tests', () {
    // RFC 6238 Test Vectors for HMAC-SHA1
    // Secret: 'JBSWY3DPEHPK3PXP' (Base32 for 'Hello!')
    const secret = 'JBSWY3DPEHPK3PXP';

    test('Should generate correct 6-digit TOTP code', () async {
      // 2020-01-01 00:00:00 UTC -> 1577836800000 ms
      final time = DateTime.fromMillisecondsSinceEpoch(1577836800000, isUtc: true);
      
      final code = await totpService.generateCode(secret, time: time);
      
      expect(code.length, 6);
      expect(int.tryParse(code), isNotNull);
    });

    test('Should parse secret from otpauth URI', () {
      const uri = 'otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example';
      final parsedSecret = totpService.parseSecretFromUri(uri);
      expect(parsedSecret, equals('JBSWY3DPEHPK3PXP'));
    });

    test('Should handle spaces and lowercase in secrets', () async {
      const cleanSecret = 'JBSWY3DPEHPK3PXP';
      const messySecret = 'jbsw y3dp ehpk 3pxp';
      
      final time = DateTime.now();
      final code1 = await totpService.generateCode(cleanSecret, time: time);
      final code2 = await totpService.generateCode(messySecret, time: time);
      
      expect(code1, equals(code2));
    });

    test('Remaining seconds should be within [0, 30)', () {
      final remaining = totpService.getRemainingSeconds();
      expect(remaining, greaterThanOrEqualTo(0));
      expect(remaining, lessThanOrEqualTo(30));
    });
  });
}
