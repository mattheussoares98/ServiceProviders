import 'package:clean_architecture/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final faker = Faker();
  late NonEmptyValidator sut;

  setUp(() {
    sut = NonEmptyValidator();
  });

  group('NonEmptyValidator', () {
    test('Should return true for a non-empty string', () {
      // Use faker to generate a random non-empty string
      final nonEmptyString = faker.lorem.sentence();
      expect(sut.isValid(nonEmptyString), isTrue);
    });

    test('Should return true for a string with only whitespace', () {
      // This is an important edge case. A string of spaces is not empty.
      // If you need to treat this as invalid, you would use `value.trim().isNotEmpty`.
      const whitespaceString = '   ';
      expect(sut.isValid(whitespaceString), isTrue);
    });

    test('Should return false for an empty string', () {
      final isValid = sut.isValid('');

      expect(isValid, isFalse);
      // We can also confirm the error message is correct
      expect(sut.errorMessage, isNotEmpty);
    });

    test('Should return false for a null value', () {
      final isValid = sut.isValid(null);

      expect(isValid, isFalse);
      expect(sut.errorMessage, isNotEmpty);
    });
  });
}
