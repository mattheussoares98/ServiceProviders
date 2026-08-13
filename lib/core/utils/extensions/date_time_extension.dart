// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String formatDate([DateFormatType type = DateFormatType.ddMMyyyy]) {
    return DateFormat(type.pattern).format(this);
  }

  String toIsoUtcString() => toUtc().toIso8601String();
}

enum DateFormatType {
  yMd('yMd'),
  yMMMMd('yMMMMd'),
  yMMMd('yMMMd'),
  yMMMEd('yMMMEd'),
  yMMMMEEEEd('yMMMMEEEEd'),
  yMdHm('yMdHm'),
  Hm('Hm'),
  Hms('Hms'),
  ddMMyyyy('dd/MM/yyyy'),
  ddMMyyyyHHmm('dd/MM/yyyy HH:mm');

  const DateFormatType(this.pattern);
  final String pattern;
}
