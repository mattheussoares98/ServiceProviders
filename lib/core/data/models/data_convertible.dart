import 'package:clean_architecture/core/utils/type_defs.dart';

abstract interface class DataConvertible<R> {
  R toEntity();
  MapDynamic toJson();
}
