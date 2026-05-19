import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:clean_architecture/shared_ui/utils/validators/string_validator.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/validators/mock_failure_validator.dart';
import '../mocks/validators/mock_success_validator.dart';

class _TestValidator implements StringValidator {
  _TestValidator(this._isValidFn, this.errorMessage);
  final bool Function(String?) _isValidFn;
  @override
  final String errorMessage;
  @override
  bool isValid(String? value) => _isValidFn(value);
}

void main() {
  group('FormValidators.compose', () {
    test('Should return null when the list of validators is empty', () {
      final composedValidator = FormValidators.compose([]);
      final result = composedValidator(faker.lorem.word());
      expect(result, isNull);
    });

    test('Should return null when all validators pass', () {
      final composedValidator = FormValidators.compose([
        MockSuccessValidator(),
        MockSuccessValidator(),
      ]);
      final result = composedValidator(faker.lorem.word());
      expect(result, isNull);
    });

    test(
      'Should return the error message of the first validator that fails',
      () {
        final error1 = faker.lorem.sentence();
        final error2 = faker.lorem.sentence();

        final composedValidator = FormValidators.compose([
          MockFailureValidator(error1),
          MockFailureValidator(error2),
        ]);
        final result = composedValidator(faker.lorem.word());

        expect(result, error1);
      },
    );

    test(
      'Should return the error message of the second validator if the first passes',
      () {
        final error2 = faker.lorem.sentence();
        final composedValidator = FormValidators.compose([
          MockSuccessValidator(),
          MockFailureValidator(error2),
        ]);
        final result = composedValidator(faker.lorem.word());
        expect(result, error2);
      },
    );

    test('Should correctly pass the input value to each validator', () {
      final inputValue = faker.internet.email();
      String? receivedValue;

      final captorValidator = MockSuccessValidator();

      bool spiedIsValid(String? value) {
        receivedValue = value;
        return captorValidator.isValid(value);
      }

      final composedValidator = FormValidators.compose([
        _TestValidator(spiedIsValid, ''),
      ]);

      composedValidator(inputValue);
      expect(receivedValue, inputValue);
    });
  });
}
