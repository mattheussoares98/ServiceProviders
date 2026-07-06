import 'package:o_jogo_da_obra/shared_ui/utils/validators/string_validator.dart';

class MockFailureValidator implements StringValidator {
  MockFailureValidator(this.message);
  final String message;

  @override
  String get errorMessage => message;

  @override
  bool isValid(String? value) => false;
}
