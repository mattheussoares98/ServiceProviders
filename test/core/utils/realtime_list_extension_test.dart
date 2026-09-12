import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/realtime_list_extension.dart';

class _TestItem {
  const _TestItem({required this.id, required this.name, this.deletedAt});
  final String id;
  final String name;
  final DateTime? deletedAt;
}

void main() {
  group('RealtimeListExtension Tests', () {
    const item1 = _TestItem(id: '1', name: 'Item 1');
    const item2 = _TestItem(id: '2', name: 'Item 2');
    const item3 = _TestItem(id: '3', name: 'Item 3');

    test('insert adds new item to the beginning by default', () {
      final list = [item1, item2];
      const newItem = _TestItem(id: '3', name: 'Item 3');

      final result = list.applyRealtimeEvent(
        event: const RealtimeEvent(
          eventType: RealtimeEventType.insert,
          id: '3',
          entity: newItem,
        ),
        idSelector: (item) => item.id,
      );

      expect(result.length, 3);
      expect(result.first, newItem);
      expect(result[1], item1);
      expect(result[2], item2);
    });

    test('insert updates item if already present', () {
      final list = [item1, item2];
      const updatedItem1 = _TestItem(id: '1', name: 'Updated Item 1');

      final result = list.applyRealtimeEvent(
        event: const RealtimeEvent(
          eventType: RealtimeEventType.insert,
          id: '1',
          entity: updatedItem1,
        ),
        idSelector: (item) => item.id,
      );

      expect(result.length, 2);
      expect(result.first, updatedItem1);
      expect(result[1], item2);
    });

    test('insert ignores soft-deleted item', () {
      final list = [item1];
      final softDeletedItem = _TestItem(
        id: '2',
        name: 'Item 2',
        deletedAt: DateTime.now(),
      );

      final result = list.applyRealtimeEvent(
        event: RealtimeEvent(
          eventType: RealtimeEventType.insert,
          id: '2',
          entity: softDeletedItem,
        ),
        idSelector: (item) => item.id,
        isDeleted: (item) => item.deletedAt != null,
      );

      expect(result.length, 1);
      expect(result, [item1]);
    });

    test('update replaces existing item', () {
      final list = [item1, item2];
      const updatedItem2 = _TestItem(id: '2', name: 'Updated Item 2');

      final result = list.applyRealtimeEvent(
        event: const RealtimeEvent(
          eventType: RealtimeEventType.update,
          id: '2',
          entity: updatedItem2,
        ),
        idSelector: (item) => item.id,
      );

      expect(result.length, 2);
      expect(result[0], item1);
      expect(result[1], updatedItem2);
    });

    test('update appends item if not present and not soft-deleted', () {
      final list = [item1];
      const newItem = _TestItem(id: '3', name: 'Item 3');

      final result = list.applyRealtimeEvent(
        event: const RealtimeEvent(
          eventType: RealtimeEventType.update,
          id: '3',
          entity: newItem,
        ),
        idSelector: (item) => item.id,
      );

      expect(result.length, 2);
      expect(result.contains(newItem), isTrue);
    });

    test('update removes item if marked as soft-deleted', () {
      final list = [item1, item2, item3];
      final softDeletedItem2 = _TestItem(
        id: '2',
        name: 'Item 2',
        deletedAt: DateTime.now(),
      );

      final result = list.applyRealtimeEvent(
        event: RealtimeEvent(
          eventType: RealtimeEventType.update,
          id: '2',
          entity: softDeletedItem2,
        ),
        idSelector: (item) => item.id,
        isDeleted: (item) => item.deletedAt != null,
      );

      expect(result.length, 2);
      expect(result.any((item) => item.id == '2'), isFalse);
    });

    test('delete removes item by id', () {
      final list = [item1, item2];

      final result = list.applyRealtimeEvent(
        event: const RealtimeEvent(
          eventType: RealtimeEventType.delete,
          id: '1',
        ),
        idSelector: (item) => item.id,
      );

      expect(result.length, 1);
      expect(result.first, item2);
    });

    test('delete does nothing if item id not found', () {
      final list = [item1, item2];

      final result = list.applyRealtimeEvent(
        event: const RealtimeEvent(
          eventType: RealtimeEventType.delete,
          id: '999',
        ),
        idSelector: (item) => item.id,
      );

      expect(result.length, 2);
      expect(result, [item1, item2]);
    });
  });
}
