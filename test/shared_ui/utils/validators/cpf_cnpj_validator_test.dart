import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/cpf_cnpj_validator.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CpfCnpjValidator sut;

  setUp(() {
    sut = CpfCnpjValidator();
  });

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
    expect(sut.isValid('39367504834'), false);
    expect(sut.errorMessage, 'CPF inválido'.hardcoded);
  });
  test('Should return null if is valid CPF', () {
    expect(sut.isValid('39367504837'), true);
    expect(sut.errorMessage, '');
  });
  test('Should return error if CNPJ is short', () {
    expect(sut.isValid('0586550300014'), false);
    expect(sut.errorMessage, 'CNPJ inválido'.hardcoded);
  });
  test('Should return null if cnpj is valid', () {
    expect(sut.isValid('05865503000143'), true);
    expect(sut.errorMessage, '');
  });
  test('Should return error if is not int value', () {
    expect(sut.isValid(faker.lorem.word()), false);
    expect(sut.errorMessage, 'Digite somente números'.hardcoded);
  });
}
