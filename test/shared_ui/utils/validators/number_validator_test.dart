import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/number_validator.dart';

void main() {
  test('Allow decimal', () {
    final sut = NumberValidator(allowDecimal: true);
    //true result
    expect(sut.isValid('1,00'), isTrue);
    expect(sut.isValid('1.00'), isTrue);
    expect(sut.isValid('145619,99'), isTrue);
    expect(sut.isValid('145619.99'), isTrue);
    expect(sut.isValid('145619991'), isTrue);

    //false result
    expect(sut.isValid('145619,99.1'), isFalse);
    expect(sut.isValid('145619.99,1'), isFalse);
    expect(sut.isValid('14561999,1z'), isFalse);
  });
  test('Allow decimal with maximum decimal houses', () {
    final sut = NumberValidator(allowDecimal: true, maxDecimalHouses: 3);
    //true result
    expect(sut.isValid('1,001'), isTrue);
    expect(sut.isValid('1.0012'), isFalse);

    //false result
    expect(sut.isValid('145619,99.1'), isFalse);
    expect(sut.isValid('145619.99,1'), isFalse);
  });

  test('Dont allow decimal', () {
    final sut = NumberValidator(allowDecimal: false);
    //true result
    expect(sut.isValid('1001'), isTrue);

    //false result
    expect(sut.isValid('1,001'), isFalse);
    expect(sut.isValid('1.001'), isFalse);
    expect(sut.isValid('145619,991'), isFalse);
    expect(sut.isValid('145619.991'), isFalse);
    expect(sut.isValid('145619,99.1'), isFalse);
    expect(sut.isValid('145619.99,1'), isFalse);
  });

  test('Needs be greater than zero', () {
    final sut = NumberValidator(allowDecimal: false);
    expect(sut.isValid('0'), isFalse);
  });

  test('DONT needs be greater than zero', () {
    final sut = NumberValidator(
      allowDecimal: false,
      needsBeGreaterThanZero: false,
    );
    expect(sut.isValid('0'), isTrue);
  });
  test('Allow empty value', () {
    final sut = NumberValidator(allowDecimal: true, allowEmptyValue: true);

    expect(sut.isValid(''), isTrue);
  });
}
