import 'package:clean_architecture/shared_ui/utils/validators/ip_validator.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock the StringHardcoded extension to return the base string.
// This is necessary to get a predictable error message.
extension StringHardcoded on String {
  String get hardcoded => this;
}

void main() {
  late IpValidator sut;

  setUp(() {
    sut = IpValidator();
  });

  group('IpValidator', () {
    // --- Test cases that should pass (return true) ---
    group('Valid IPs', () {
      test('should return true for a standard local IP', () {
        expect(sut.isValid('192.168.0.1'), isTrue);
      });

      test('should return true for a standard public IP', () {
        expect(sut.isValid('8.8.8.8'), isTrue);
      });

      test('should return true for the 0.0.0.0 IP', () {
        expect(sut.isValid('0.0.0.0'), isTrue);
      });

      test('should return true for the 255.255.255.255 IP', () {
        expect(sut.isValid('255.255.255.255'), isTrue);
      });

      test('should return true and trim whitespace', () {
        expect(sut.isValid('  127.0.0.1  '), isTrue);
      });
    });

    // --- Test cases that should fail (return false) ---
    group('Invalid IPs', () {
      test('should return false for a null value', () {
        expect(sut.isValid(null), isFalse);
      });

      test('should return false for an empty string', () {
        expect(sut.isValid(''), isFalse);
      });

      test('should return false for a string with only whitespace', () {
        expect(sut.isValid('   '), isFalse);
      });

      test('should return false for an IP with a number > 255', () {
        expect(sut.isValid('192.168.0.256'), isFalse);
      });

      test('should return false for an IP with letters', () {
        expect(sut.isValid('192.168.0.1a'), isFalse);
      });

      test('should return false for an IP with internal spaces', () {
        expect(sut.isValid('192.168. 0.1'), isFalse);
      });

      test('should return false for an IP with too few parts', () {
        expect(sut.isValid('192.168.0'), isFalse);
      });

      test('should return false for an IP with too many parts', () {
        expect(sut.isValid('192.168.0.1.10'), isFalse);
      });

      test('should return false for an IP with a trailing dot', () {
        expect(sut.isValid('192.168.0.1.'), isFalse);
      });

      test('should return false for a non-IP string', () {
        expect(sut.isValid('not an ip'), isFalse);
      });
    });

    // --- Test error message ---
    group('Error Message', () {
      test('should set the correct error message on failure', () {
        // Arrange
        const expectedMessage = 'Formato de IP inválido';

        // Act
        sut.isValid('1.2.3.256');

        // Assert
        expect(sut.errorMessage, expectedMessage);
      });

      test(
        'should have a default error message even if isValid is not called',
        () {
          expect(sut.errorMessage, 'Formato de IP inválido');
        },
      );
    });
  });
}
