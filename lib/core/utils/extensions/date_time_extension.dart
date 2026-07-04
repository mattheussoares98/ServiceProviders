// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String formatDate([DateFormatType type = DateFormatType.yMMMd]) {
    return DateFormat(type.name).format(this);
  }
}

enum DateFormatType { yMd, yMMMMd, yMMMd, yMMMEd, yMMMMEEEEd, yMdHm, Hm, Hms }
