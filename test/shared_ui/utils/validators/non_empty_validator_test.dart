import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

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

    test('Should return false for a string with only whitespace', () {
      const whitespaceString = '   ';
      expect(sut.isValid(whitespaceString), isFalse);
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
