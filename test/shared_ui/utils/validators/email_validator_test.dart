import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/email_validator.dart';

void main() {
  late EmailValidator sut;

  setUp(() {
    sut = EmailValidator();
  });

  group('EmailValidator', () {
    test(
      'Should return true for a valid email and error message should be null',
      () {
        final validEmail = faker.internet.email();
        expect(sut.isValid(validEmail), true);
      },
    );

    test('Should return false for an invalid email and set error message', () {
      final invalidEmail = faker.lorem.word();
      expect(sut.isValid(invalidEmail), false);
      expect(sut.errorMessage, 'Por favor, insira um e-mail válido'.hardcoded);
    });

    test('Should return false for an empty string and set error message', () {
      expect(sut.isValid(''), false);
      expect(sut.errorMessage, 'Por favor, insira um e-mail válido'.hardcoded);
    });

    test('Should return false for a null value and set error message', () {
      expect(sut.isValid(null), false);
      expect(sut.errorMessage, 'Por favor, insira um e-mail válido'.hardcoded);
    });
  });

  group('EmailValidator isRequired false', () {
    setUp(() {
      sut = EmailValidator(isRequired: false);
    });

    test(
      'Should return true for a valid email and error message should be null',
      () {
        final validEmail = faker.internet.email();
        expect(sut.isValid(validEmail), true);
      },
    );

    test('Should return false for an invalid email and set error message', () {
      final invalidEmail = faker.lorem.word();
      expect(sut.isValid(invalidEmail), false);
      expect(sut.errorMessage, 'Por favor, insira um e-mail válido'.hardcoded);
    });

    test('Should return true for an empty string', () {
      expect(sut.isValid(''), true);
    });

    test('Should return true for a null value', () {
      expect(sut.isValid(null), true);
    });
  });
}
