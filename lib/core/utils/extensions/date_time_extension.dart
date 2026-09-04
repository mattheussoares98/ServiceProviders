// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

export 'string_extension.dart';

extension DateTimeExtension on DateTime {
  String formatDate([DateFormatType type = DateFormatType.ddMMyyyy]) {
    return DateFormat(type.pattern).format(this);
  }

  String toIsoUtcString() => toUtc().toIso8601String();

  Duration elapsedSince([DateTime? now]) =>
      (now ?? DateTime.now()).difference(this);

  int elapsedSeconds([DateTime? now]) => elapsedSince(now).inSeconds;
}

enum DateFormatType {
  // Standard skeletons
  d('d'),
  E('E'),
  EEEE('EEEE'),
  LLL('LLL'),
  LLLL('LLLL'),
  M('M'),
  Md('Md'),
  MEd('MEd'),
  MMM('MMM'),
  MMMd('MMMd'),
  MMMEd('MMMEd'),
  MMMM('MMMM'),
  MMMMd('MMMMd'),
  MMMMEEEEd('MMMMEEEEd'),
  QQQ('QQQ'),
  QQQQ('QQQQ'),
  y('y'),
  yM('yM'),
  yMd('yMd'),
  yMEd('yMEd'),
  yMMM('yMMM'),
  yMMMd('yMMMd'),
  yMMMEd('yMMMEd'),
  yMMMM('yMMMM'),
  yMMMMd('yMMMMd'),
  yMMMMEEEEd('yMMMMEEEEd'),
  yQQQ('yQQQ'),
  yQQQQ('yQQQQ'),
  H('H'),
  Hm('Hm'),
  Hms('Hms'),
  j('j'),
  jm('jm'),
  jms('jms'),
  jmv('jmv'),
  jmz('jmz'),
  jv('jv'),
  jz('jz'),
  m('m'),
  ms('ms'),
  s('s'),
  yMdH('yMdH'),
  yMdHm('yMdHm'),
  yMdHms('yMdHms'),
  // Custom patterns
  ddMMyyyy('dd/MM/yyyy'),
  ddMMyyyyHHmm('dd/MM/yyyy HH:mm'),
  ddMMyyyyHHmmss('dd/MM/yyyy HH:mm:ss'),
  HHmm('HH:mm'),
  HHmmss('HH:mm:ss');

  const DateFormatType(this.pattern);
  final String pattern;
}
