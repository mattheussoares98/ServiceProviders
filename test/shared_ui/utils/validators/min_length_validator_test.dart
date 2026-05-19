import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/min_length_validator.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MinLengthValidator sut;

  group('MinLengthValidator', () {
    const minLength = 8;

    setUp(() {
      sut = MinLengthValidator(minLength);
    });

    test(
      'Should return true if string length is exactly the minimum length',
      () {
        final value = faker.randomGenerator.string(30, min: minLength);
        expect(sut.isValid(value), isTrue);
      },
    );

    test(
      'Should return true if string length is greater than the minimum length',
      () {
        final value = faker.randomGenerator.string(30, min: minLength + 5);
        expect(sut.isValid(value), isTrue);
      },
    );

    test(
      'Should return false if string length is less than the minimum length',
      () {
        final value = faker.randomGenerator.string(minLength - 1);
        final isValid = sut.isValid(value);

        expect(isValid, isFalse);
        expect(
          sut.errorMessage,
          'Precisa ter pelo menos $minLength caracteres'.hardcoded,
        );
      },
    );

    test('Should return false for an empty string if minLength > 0', () {
      final isValid = sut.isValid('');

      expect(isValid, isFalse);
      expect(
        sut.errorMessage,
        'Precisa ter pelo menos $minLength caracteres'.hardcoded,
      );
    });

    // This test will fail with the current implementation. See the note below.
    test('Should return false if value is null', () {
      final isValid = sut.isValid(null);

      expect(isValid, isFalse);
      expect(
        sut.errorMessage,
        'Precisa ter pelo menos $minLength caracteres'.hardcoded,
      );
    });
  });
}
