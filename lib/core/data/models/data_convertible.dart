abstract interface class DataConvertible<R> {
  R toEntity();
  Map<String, dynamic> toJson();
}
