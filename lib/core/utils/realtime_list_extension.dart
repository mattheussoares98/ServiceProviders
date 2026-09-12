import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';

extension RealtimeListExtension<T> on List<T> {
  /// Applies a [RealtimeEvent] to this list and returns the updated list.
  ///
  /// - [event]: The realtime event (insert, update, delete).
  /// - [idSelector]: Extracts the unique identifier from an item [T].
  /// - [isDeleted]: Optional predicate to determine if an entity is soft-deleted.
  /// - [insertAtStart]: If true, newly inserted items are placed at index 0 (default: true).
  List<T> applyRealtimeEvent({
    required RealtimeEvent<T> event,
    required String Function(T item) idSelector,
    bool Function(T item)? isDeleted,
    bool insertAtStart = true,
  }) {
    final updatedList = List<T>.from(this);
    final entity = event.entity;

    switch (event.eventType) {
      case RealtimeEventType.insert:
        if (entity != null) {
          final deleted = isDeleted?.call(entity) ?? false;
          if (!deleted) {
            final index = updatedList.indexWhere(
              (item) => idSelector(item) == event.id,
            );
            if (index == -1) {
              if (insertAtStart) {
                updatedList.insert(0, entity);
              } else {
                updatedList.add(entity);
              }
            } else {
              updatedList[index] = entity;
            }
          }
        }
      case RealtimeEventType.update:
        if (entity != null) {
          final index = updatedList.indexWhere(
            (item) => idSelector(item) == event.id,
          );
          final deleted = isDeleted?.call(entity) ?? false;
          if (deleted) {
            if (index != -1) {
              updatedList.removeAt(index);
            }
          } else {
            if (index != -1) {
              updatedList[index] = entity;
            } else {
              if (insertAtStart) {
                updatedList.insert(0, entity);
              } else {
                updatedList.add(entity);
              }
            }
          }
        }
      case RealtimeEventType.delete:
        final index = updatedList.indexWhere(
          (item) => idSelector(item) == event.id,
        );
        if (index != -1) {
          updatedList.removeAt(index);
        }
    }

    return updatedList;
  }
}
