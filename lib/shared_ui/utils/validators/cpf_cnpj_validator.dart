import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/string_validator.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';

class CpfCnpjValidator implements StringValidator {
  CpfCnpjValidator({
    this.validateOnlyCnpj = false,
    this.validateOnlyCpf = false,
  });
  final bool validateOnlyCnpj;
  final bool validateOnlyCpf;

  @override
  String get errorMessage => _errorMessage;
  String _errorMessage = '';

  @override
  bool isValid(String? value) {
    if (value == null || value.isEmpty) {
      _errorMessage = 'Campo obrigatório'.hardcoded;
      return false;
    } else if (int.tryParse(value) == null) {
      _errorMessage = 'Digite somente números'.hardcoded;
      return false;
    }

    //CPF validations
    if (!validateOnlyCnpj) {
      if (value.length < 11) {
        _errorMessage = 'Campo muito curto'.hardcoded;
        return false;
      } else if (value.length == 11) {
        final bool cpfIsValid = CPFValidator.isValid(value);

        _errorMessage = cpfIsValid ? '' : 'CPF inválido'.hardcoded;
        return cpfIsValid;
      }
    }

    //CNPJ validations
    if (!validateOnlyCpf) {
      if (value.length < 14) {
        _errorMessage = 'Campo muito curto'.hardcoded;
        return false;
      } else if (value.length == 14) {
        final bool cnpjIsValid = CNPJValidator.isValid(value);

        _errorMessage = cnpjIsValid ? '' : 'CNPJ inválido'.hardcoded;
        return cnpjIsValid;
      }
    }

    _errorMessage = 'CPF ou CNPJ inválido'.hardcoded;
    return false;
  }
}
