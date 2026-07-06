import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

abstract interface class DataConvertible<R> {
  R toEntity();
  MapDynamic toJson();
}
