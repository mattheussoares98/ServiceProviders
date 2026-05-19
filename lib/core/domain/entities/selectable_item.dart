import 'package:flutter/material.dart';

abstract class SelectableItem<T> {
  String get name;
  T get value;
  Color? get color;
}
