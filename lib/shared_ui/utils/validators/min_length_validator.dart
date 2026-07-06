import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/string_validator.dart';

class MinLengthValidator implements StringValidator {
  MinLengthValidator(this.minLength);
  final int minLength;

  @override
  String get errorMessage =>
      'Precisa ter pelo menos $minLength caracteres'.hardcoded;

  @override
  bool isValid(String? value) {
    return value != null && value.length >= minLength;
  }
}
