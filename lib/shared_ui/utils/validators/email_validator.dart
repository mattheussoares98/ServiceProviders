import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/string_validator.dart';

class EmailValidator implements StringValidator {
  EmailValidator({this.isRequired = true});

  final bool isRequired;

  @override
  String get errorMessage => 'Por favor, insira um e-mail válido'.hardcoded;

  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  bool isValid(String? value) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return true;
    }
    if (value != null && _emailRegex.hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }
}
