import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/ddd_validator.dart';

void main() {
  late DddValidator sut;

  group('DddValidator (isRequired: true)', () {
    setUp(() {
      sut = DddValidator();
    });

    test('Should return true for valid Brazilian DDDs', () {
      const validDdds = ['11', '21', '31', '41', '51', '61', '71', '81', '91'];
      for (final ddd in validDdds) {
        expect(sut.isValid(ddd), isTrue, reason: 'DDD $ddd should be valid');
      }
    });

    test('Should return false for invalid Brazilian DDDs', () {
      const invalidDdds = ['00', '10', '20', '30', '90', 'abc', '1', '111'];
      for (final ddd in invalidDdds) {
        expect(sut.isValid(ddd), isFalse, reason: 'DDD $ddd should be invalid');
      }
    });

    test('Should return false for empty string when isRequired is true', () {
      expect(sut.isValid(''), isFalse);
      expect(sut.errorMessage, 'DDD inválido'.hardcoded);
    });

    test('Should return false for null when isRequired is true', () {
      expect(sut.isValid(null), isFalse);
      expect(sut.errorMessage, 'DDD inválido'.hardcoded);
    });
  });

  group('DddValidator (isRequired: false)', () {
    setUp(() {
      sut = DddValidator(isRequired: false);
    });

    test('Should return true for valid Brazilian DDDs', () {
      expect(sut.isValid('11'), isTrue);
      expect(sut.isValid('21'), isTrue);
    });

    test('Should return false for invalid non-empty Brazilian DDDs', () {
      expect(sut.isValid('00'), isFalse);
      expect(sut.isValid('1'), isFalse);
      expect(sut.isValid('abc'), isFalse);
    });

    test('Should return true for empty string when isRequired is false', () {
      expect(sut.isValid(''), isTrue);
    });

    test('Should return true for null when isRequired is false', () {
      expect(sut.isValid(null), isTrue);
    });
  });
}