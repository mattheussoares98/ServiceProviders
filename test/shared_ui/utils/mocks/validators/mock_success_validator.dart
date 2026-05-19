import 'package:clean_architecture/shared_ui/utils/validators/string_validator.dart';

class MockSuccessValidator implements StringValidator {
  @override
  String get errorMessage => '';

  @override
  bool isValid(String? value) => true;
}
