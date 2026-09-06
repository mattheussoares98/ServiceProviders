import 'package:faker/faker.dart';

abstract final class FactoryHelpers {
  static DateTime makeDateTime() {
    final dt = faker.date.dateTime();
    return DateTime.utc(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
    );
  }

  static String makeCompanyName() => faker.company.name();
  static String makeId() => faker.guid.guid();
  static String makeWord() => faker.lorem.word();
  static String makePhrase() => faker.lorem.sentence();
  static String makeString([int? length]) =>
      faker.randomGenerator.string(length ?? 10);
  static bool makeBool() => faker.randomGenerator.boolean();
  static int makeInt(int max, {int min = 0}) =>
      faker.randomGenerator.integer(max, min: min);
  static double makeDouble() => faker.randomGenerator.decimal();
  static String makeHttps() => faker.internet.httpsUrl();
  static String makeEmail() => faker.internet.email();
  static String makePassword() => faker.internet.password();
  static String makePersonName() => faker.person.name();
  static String makeUrl() => faker.internet.httpsUrl();
}
