import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/string_validator.dart';

class NonEmptyValidator implements StringValidator {
  @override
  String get errorMessage => 'Campo obrigatório'.hardcoded;

  @override
  bool isValid(String? value) {
    return value?.isNotEmpty ?? false;
  }
}
