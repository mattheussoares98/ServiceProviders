import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/string_validator.dart';

class DddValidator implements StringValidator {
  @override
  String get errorMessage => 'DDD inválido'.hardcoded;

  /// A complete set of all valid DDDs in Brazil for fast lookups.
  static const Set<String> _validDdds = {
    // SUDESTE
    // São Paulo
    '11', '12', '13', '14', '15', '16', '17', '18', '19',
    // Rio de Janeiro
    '21', '22', '24',
    // Espírito Santo
    '27', '28',
    // Minas Gerais
    '31', '32', '33', '34', '35', '37', '38',

    // SUL
    // Paraná
    '41', '42', '43', '44', '45', '46',
    // Santa Catarina
    '47', '48', '49',
    // Rio Grande do Sul
    '51', '53', '54', '55',

    // CENTRO-OESTE
    // Distrito Federal
    '61',
    // Goiás
    '62', '64',
    // Tocantins
    '63',
    // Mato Grosso
    '65', '66',
    // Mato Grosso do Sul
    '67',
    // Acre
    '68',
    // Rondônia
    '69',

    // NORDESTE
    // Bahia
    '71', '73', '74', '75', '77',
    // Sergipe
    '79',
    // Pernambuco
    '81', '87',
    // Alagoas
    '82',
    // Paraíba
    '83',
    // Rio Grande do Norte
    '84',
    // Ceará
    '85', '88',
    // Piauí
    '86', '89',
    // Maranhão
    '98', '99',

    // NORTE
    // Pará
    '91', '93', '94',
    // Amazonas
    '92', '97',
    // Roraima
    '95',
    // Amapá
    '96',
  };

  @override
  bool isValid(String? value) {
    if (value == null || value.length != 2) {
      return false;
    }
    // The value must be in our set of valid DDDs.
    return _validDdds.contains(value);
  }
}
