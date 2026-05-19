import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/string_validator.dart';

class UrlValidator implements StringValidator {
  UrlValidator({this.shouldBeHttps, this.allowEmptyValue});
  final bool? shouldBeHttps;
  final bool? allowEmptyValue;

  @override
  String get errorMessage => _errorMessage;
  String _errorMessage = '';

  @override
  bool isValid(String? value) {
    // 1. Basic check for null or empty string
    if ((allowEmptyValue ?? false) && (value == null || value.isEmpty)) {
      return true;
    } else if (value == null || value.isEmpty) {
      _errorMessage = 'Campo obrigatório'.hardcoded;
      return false;
    }

    // 2. Try to parse the string into a Uri object
    final uri = Uri.tryParse(value);

    // 3. Validate that the URI has a valid scheme and a host
    // We check for http or https to ensure it is a web URL
    final bool hasValidScheme = uri?.hasScheme ?? false;
    final bool isHttp = uri?.scheme == 'http' || uri?.scheme == 'https';
    final bool hasHost = uri?.host.isNotEmpty ?? false;

    if (uri == null || !hasValidScheme || !isHttp || !hasHost) {
      _errorMessage = 'URL inválida'.hardcoded;
      return false;
    }

    if ((shouldBeHttps ?? false) && uri.scheme != 'https') {
      _errorMessage = 'A URL precisa ser HTTPS'.hardcoded;
      return false;
    }

    // 4. Clear error message and return true if all checks pass
    _errorMessage = '';
    return true;
  }
}
