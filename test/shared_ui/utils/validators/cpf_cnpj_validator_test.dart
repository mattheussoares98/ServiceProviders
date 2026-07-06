import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/cpf_cnpj_validator.dart';

void main() {
  late CpfCnpjValidator sut;

  setUp(() {
    sut = CpfCnpjValidator();
  });

  const validCnpj = '64696534000187';
  const validCpf = '26843676049';

  test('Should return error if value is null', () {
    expect(sut.isValid(null), false);
    expect(sut.errorMessage, 'Campo obrigatório'.hardcoded);
  });

  test('Should return error if value is empty', () {
    expect(sut.isValid(''), false);
    expect(sut.errorMessage, 'Campo obrigatório'.hardcoded);
  });

  test('Should return error if value is short', () {
    expect(
      sut.isValid(faker.randomGenerator.integer(10, min: 1).toString()),
      false,
    );
    expect(sut.errorMessage, 'Campo muito curto'.hardcoded);
  });

  test('Should return error if is invalid cpf', () {
    expect(sut.isValid('10101010101'), false);
    expect(sut.errorMessage, 'CPF inválido'.hardcoded);
  });
  test('Should return null if is valid CPF', () {
    expect(sut.isValid(validCpf), true);
    expect(sut.errorMessage, '');
  });
  test('Should return error if CNPJ is invalid', () {
    expect(sut.isValid('01010101010101'), false);
    expect(sut.errorMessage, 'CNPJ inválido'.hardcoded);
  });
  test('Should return null if cnpj is valid', () {
    expect(sut.isValid(validCnpj), true);
    expect(sut.errorMessage, '');
  });
  test('Should return error if is not int value', () {
    expect(sut.isValid(faker.lorem.word()), false);
    expect(sut.errorMessage, 'Digite somente números'.hardcoded);
  });

  group('Validate only CPF', () {
    final validator = CpfCnpjValidator(validateOnlyCpf: true);

    test('Should return false if it is a valid CNPJ', () {
      expect(validator.isValid(validCnpj), false);
      expect(validator.errorMessage, 'CPF ou CNPJ inválido'.hardcoded);
    });
  });
  group('Validate only CNPJ', () {
    final validator = CpfCnpjValidator(validateOnlyCnpj: true);

    test('Should return false if it is a valid CPF', () {
      expect(validator.isValid(validCpf), false);
      expect(validator.errorMessage, isNotEmpty);
    });
  });
}
