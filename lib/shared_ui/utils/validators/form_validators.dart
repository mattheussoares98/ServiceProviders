import 'package:clean_architecture/shared_ui/utils/validators/string_validator.dart';

class FormValidators {
  /// A static method that takes a list of validators and returns a
  /// `FormFieldValidator` function.
  ///
  /// It iterates through each validator in the list. The first one that fails
  /// will have its `errorMessage` returned. If all validators pass, it returns `null`.
  static String? Function(String?) compose(List<StringValidator> validators) {
    return (String? value) {
      for (final validator in validators) {
        if (!validator.isValid(value)) {
          return validator.errorMessage;
        }
      }
      return null;
    };
  }
}
