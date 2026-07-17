import 'package:collection/collection.dart';

enum AppMode {
  internal('internal'),
  provider('provider');

  const AppMode(this.name);
  final String name;

  static AppMode? fromName(String? name) =>
      AppMode.values.firstWhereOrNull((e) => e.name == name);
}
