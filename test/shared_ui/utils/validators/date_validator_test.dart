import 'package:clean_architecture/shared_ui/utils/validators/date_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Define a fixed period to use for all tests
  final startDate = DateTime(2025);
  final endDate = DateTime(2025, 1, 31);

  late DateValidator sut;

  setUp(() {
    // Instantiate the validator with the required period
    sut = DateValidator(minimumDate: startDate, maximumDate: endDate);
  });

  group('DateValidator', () {
    group('Valid Dates including day', () {
      test('should return true for a date within the allowed period', () {
        expect(sut.isValid('15/01/2025'), true);
      });

      test('should return true for a date exactly on the start date', () {
        expect(sut.isValid('01/01/2025'), true);
      });

      test('should return true for a date exactly on the end date', () {
        expect(sut.isValid('31/01/2025'), true);
      });

      test('should return true when allow empty date', () {
        final allowEmptyDate = DateValidator(
          minimumDate: startDate,
          maximumDate: endDate,
          allowEmptyDate: true,
        );

        expect(allowEmptyDate.isValid(''), true);
      });
    });

    group('Valid Dates without day (MM/YYYY)', () {
      late DateValidator monthOnlySut;
      final rangeStart = DateTime(2025, 5, 15); // Mid-month start
      final rangeEnd = DateTime(2026, 12);

      setUp(() {
        monthOnlySut = DateValidator(
          minimumDate: rangeStart,
          maximumDate: rangeEnd,
          includeDay: false,
        );
      });

      test('should return true for a month within the allowed period', () {
        expect(monthOnlySut.isValid('06/2025'), true);
      });

      test(
        'should return true for the START month even if today is after the start day',
        () {
          // Even if range starts May 15, 05/2025 is valid because we normalize to the 1st
          expect(monthOnlySut.isValid('05/2025'), true);
        },
      );

      test('should return true for the END month', () {
        expect(monthOnlySut.isValid('12/2026'), true);
      });
    });

    group('Invalid Dates without day (MM/YYYY)', () {
      late DateValidator monthOnlySut;
      final rangeStart = DateTime(2025, 5);
      final rangeEnd = DateTime(2026, 12, 31);

      setUp(() {
        monthOnlySut = DateValidator(
          minimumDate: rangeStart,
          maximumDate: rangeEnd,
          includeDay: false,
        );
      });

      test('should return false for a month BEFORE the range', () {
        expect(monthOnlySut.isValid('04/2025'), false);
      });

      test('should return false for a month AFTER the range', () {
        expect(monthOnlySut.isValid('01/2027'), false);
      });

      test(
        'should return false for invalid format when includeDay is false',
        () {
          // Should not accept DD/MM/YYYY when includeDay is false
          expect(monthOnlySut.isValid('15/05/2025'), false);
        },
      );
    });

    group('Invalid Dates', () {
      test('should return false for a null value', () {
        expect(sut.isValid(null), false);
      });

      test('should return false for an empty string', () {
        expect(sut.isValid(''), false);
      });

      test('should return false for an invalid format', () {
        sut.isValid('not-a-date');
        expect(sut.errorMessage, isNotEmpty);
      });

      test('should return false for an impossible date', () {
        expect(sut.isValid('31/02/2025'), false);
      });

      test('should return false for a date BEFORE the allowed period', () {
        final isValid = sut.isValid('31/12/2024');
        expect(isValid, false);
        expect(sut.errorMessage, isNotEmpty);
      });

      test('should return false for a date AFTER the allowed period', () {
        final isValid = sut.isValid('01/02/2025');
        expect(isValid, false);
        expect(sut.errorMessage, isNotEmpty);
      });
    });
  });
}
