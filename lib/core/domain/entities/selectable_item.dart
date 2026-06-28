import 'package:flutter/material.dart';

abstract class SelectableItem<T> {
  String get name;
  T get value;
  Color? get color;
}

class SelectableItemImpl<T> implements SelectableItem<T> {
  const SelectableItemImpl({
    required this.name,
    required this.value,
    this.color,
  });

  @override
  final String name;
  @override
  final T value;
  @override
  final Color? color;
}

