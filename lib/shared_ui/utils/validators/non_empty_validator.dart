import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/string_validator.dart';

class NonEmptyValidator implements StringValidator {
  @override
  String get errorMessage => 'Campo obrigatório'.hardcoded;

  @override
  bool isValid(String? value) {
    return value?.isNotEmpty ?? false;
  }
}
