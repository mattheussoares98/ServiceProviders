import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

class FakeDto implements DataConvertible<String> {
  const FakeDto(this.value);
  final int value;

  @override
  String toEntity() => 'Mapped: $value';

  @override
  MapDynamic toJson() => {'value': value};
}

void main() {
  group('RepositoryHandler.fetchWithFallback', () {
    test('returns remote data when online', () async {
      final result = await RepositoryHandler.fetchWithFallback<int>(
        isInternetConnected: true,
        remoteCallback: () async => const SuccessState(data: 42),
      );
      expect(result, isA<SuccessState<int>>());
      expect(result.data, 42);
    });

    test('calls onRemoteSuccess when data is present', () async {
      int? callbackValue;
      await RepositoryHandler.fetchWithFallback<int>(
        isInternetConnected: true,
        remoteCallback: () async => const SuccessState(data: 99),
        onRemoteSuccess: (data) async {
          callbackValue = data;
          return const SuccessState(data: true);
        },
      );
      expect(callbackValue, 99);
    });

    test('does not call onRemoteSuccess when data is null', () async {
      var wasCalled = false;
      await RepositoryHandler.fetchWithFallback<int>(
        isInternetConnected: true,
        remoteCallback: () async => const SuccessState(data: null),
        onRemoteSuccess: (data) async {
          wasCalled = true;
          return const SuccessState(data: true);
        },
      );
      expect(wasCalled, false);
    });

    test(
      'returns local data when offline and localCallback is provided',
      () async {
        final result = await RepositoryHandler.fetchWithFallback<String>(
          isInternetConnected: false,
          remoteCallback: () async => const SuccessState(data: 'remote'),
          localCallback: () async => const SuccessState(data: 'local'),
        );
        expect(result, isA<SuccessState<String>>());
        expect(result.data, 'local');
      },
    );

    test('returns NoInternetState when offline and no localCallback', () async {
      final result = await RepositoryHandler.fetchWithFallback<double>(
        isInternetConnected: false,
        remoteCallback: () async => const SuccessState(data: 1),
      );
      expect(result.message, kNoInternet);
    });

    test('returns remote failure state when remote call fails', () async {
      final result = await RepositoryHandler.fetchWithFallback<String>(
        isInternetConnected: true,
        remoteCallback: () async => FailureState(message: 'Remote error'),
      );
      expect(result, isA<FailureState<String>>());
      expect(result.message, 'Remote error');
    });
  });

  group('RepositoryHandler.fetchWithFallbackAndMap', () {
    test('maps remote data successfully when online', () async {
      final result =
          await RepositoryHandler.fetchWithFallbackAndMap<FakeDto, String>(
            isInternetConnected: true,
            remoteCallback: () async => const SuccessState(data: FakeDto(42)),
          );
      expect(result, isA<SuccessState<String>>());
      expect(result.data, 'Mapped: 42');
    });

    test('calls onRemoteSuccess with raw data before mapping', () async {
      FakeDto? rawData;
      final result =
          await RepositoryHandler.fetchWithFallbackAndMap<FakeDto, String>(
            isInternetConnected: true,
            remoteCallback: () async => const SuccessState(data: FakeDto(99)),
            onRemoteSuccess: (data) async {
              rawData = data;
              return const SuccessState(data: true);
            },
          );
      expect(rawData?.value, 99);
      expect(result.data, 'Mapped: 99');
    });

    test('maps local data when offline', () async {
      final result =
          await RepositoryHandler.fetchWithFallbackAndMap<FakeDto, String>(
            isInternetConnected: false,
            remoteCallback: () async => const SuccessState(data: FakeDto(100)),
            localCallback: () async => const SuccessState(data: FakeDto(50)),
          );
      expect(result, isA<SuccessState<String>>());
      expect(result.data, 'Mapped: 50');
    });
  });

  group('RepositoryHandler.fetchWithFallbackAndMapList', () {
    test('maps remote list data successfully when online', () async {
      final result =
          await RepositoryHandler.fetchWithFallbackAndMapList<FakeDto, String>(
            isInternetConnected: true,
            remoteCallback: () async =>
                const SuccessState(data: [FakeDto(1), FakeDto(2)]),
          );
      expect(result, isA<SuccessState<List<String>>>());
      expect(result.data, ['Mapped: 1', 'Mapped: 2']);
    });

    test('calls onRemoteSuccess with raw list before mapping', () async {
      List<FakeDto>? rawData;
      final result =
          await RepositoryHandler.fetchWithFallbackAndMapList<FakeDto, String>(
            isInternetConnected: true,
            remoteCallback: () async => const SuccessState(data: [FakeDto(3)]),
            onRemoteSuccess: (data) async {
              rawData = data;
              return const SuccessState(data: true);
            },
          );
      expect(rawData?.length, 1);
      expect(rawData?.first.value, 3);
      expect(result.data, ['Mapped: 3']);
    });
  });

  group('RepositoryHandler.fetchFromLocalAndMap', () {
    test('maps local data successfully', () async {
      final result =
          await RepositoryHandler.fetchFromLocalAndMap<FakeDto, String>(
            localCallback: () async => const SuccessState(data: FakeDto(123)),
          );
      expect(result, isA<SuccessState<String>>());
      expect(result.data, 'Mapped: 123');
    });

    test('propagates local failure state', () async {
      final result =
          await RepositoryHandler.fetchFromLocalAndMap<FakeDto, String>(
            localCallback: () async =>
                FailureState(message: 'Local storage error'),
          );
      expect(result, isA<FailureState<String>>());
      expect(result.message, 'Local storage error');
    });
  });

  group('RepositoryHandler.fetchFromLocalAndMapList', () {
    test('maps local list data successfully', () async {
      final result =
          await RepositoryHandler.fetchFromLocalAndMapList<FakeDto, String>(
            localCallback: () async =>
                const SuccessState(data: [FakeDto(5), FakeDto(6)]),
          );
      expect(result, isA<SuccessState<List<String>>>());
      expect(result.data, ['Mapped: 5', 'Mapped: 6']);
    });

    test('propagates local failure state for list', () async {
      final result =
          await RepositoryHandler.fetchFromLocalAndMapList<FakeDto, String>(
            localCallback: () async =>
                FailureState(message: 'Local list error'),
          );
      expect(result, isA<FailureState<List<String>>>());
      expect(result.message, 'Local list error');
    });
  });

  group('RepositoryHandler.syncRealtimeStream', () {
    test('calls saveLocal and maps entity on insert event', () async {
      FakeDto? savedModel;
      final stream = Stream.value(
        const RealtimeEvent<FakeDto>(
          eventType: RealtimeEventType.insert,
          id: '123',
          entity: FakeDto(42),
        ),
      );

      final resultStream = RepositoryHandler.syncRealtimeStream<FakeDto, String>(
        stream: stream,
        saveLocal: (model) async => savedModel = model,
        deleteLocal: (_) async {},
      );

      final event = await resultStream.first;
      expect(savedModel?.value, 42);
      expect(event.eventType, RealtimeEventType.insert);
      expect(event.id, '123');
      expect(event.entity, 'Mapped: 42');
    });

    test('calls deleteLocal when update event is soft-deleted', () async {
      String? deletedId;
      FakeDto? savedModel;
      final stream = Stream.value(
        const RealtimeEvent<FakeDto>(
          eventType: RealtimeEventType.update,
          id: '123',
          entity: FakeDto(-1),
        ),
      );

      final resultStream = RepositoryHandler.syncRealtimeStream<FakeDto, String>(
        stream: stream,
        saveLocal: (model) async => savedModel = model,
        deleteLocal: (id) async => deletedId = id,
        isDeleted: (model) => model.value < 0,
      );

      final event = await resultStream.first;
      expect(deletedId, '123');
      expect(savedModel, isNull);
      expect(event.eventType, RealtimeEventType.update);
      expect(event.entity, 'Mapped: -1');
    });

    test('calls deleteLocal on delete event', () async {
      String? deletedId;
      final stream = Stream.value(
        const RealtimeEvent<FakeDto>(
          eventType: RealtimeEventType.delete,
          id: '123',
        ),
      );

      final resultStream = RepositoryHandler.syncRealtimeStream<FakeDto, String>(
        stream: stream,
        deleteLocal: (id) async => deletedId = id,
      );

      final event = await resultStream.first;
      expect(deletedId, '123');
      expect(event.eventType, RealtimeEventType.delete);
      expect(event.entity, isNull);
    });
  });

  group('RepositoryHandler.executeMutation', () {
    test('returns FailureState.noInternet when offline and localCallback is null', () async {
      final result = await RepositoryHandler.executeMutation<String>(
        isInternetConnected: false,
        remoteCallback: () async => const SuccessState(data: 'remote'),
      );

      expect(result.message, kNoInternet);
    });

    test('invokes localCallback when offline and provided', () async {
      final result = await RepositoryHandler.executeMutation<String>(
        isInternetConnected: false,
        remoteCallback: () async => const SuccessState(data: 'remote'),
        localCallback: () async => const SuccessState(data: true),
      );

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
    });

    test('returns remote failure when remoteCallback fails', () async {
      final result = await RepositoryHandler.executeMutation<String>(
        isInternetConnected: true,
        remoteCallback: () async => FailureState(
          message: 'Server error',
          statusCode: 500,
        ),
      );

      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'Server error');
      expect(result.statusCode, 500);
    });

    test('propagates local mirror failure when onRemoteSuccess fails', () async {
      final result = await RepositoryHandler.executeMutation<String>(
        isInternetConnected: true,
        remoteCallback: () async => const SuccessState(data: 'remote-data'),
        onRemoteSuccess: (data) async => FailureState<bool>(
          message: 'disk full',
          statusCode: 507,
        ),
      );

      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'disk full');
      expect(result.statusCode, 507);
    });

    test('returns SuccessState(true) when remote and local mirror succeed', () async {
      String? mirrored;
      final result = await RepositoryHandler.executeMutation<String>(
        isInternetConnected: true,
        remoteCallback: () async => const SuccessState(data: 'saved-item'),
        onRemoteSuccess: (data) async {
          mirrored = data;
          return const SuccessState(data: true);
        },
      );

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      expect(mirrored, 'saved-item');
    });

    test('handles void remoteCallback (delete operation)', () async {
      var deleted = false;
      final result = await RepositoryHandler.executeMutation<void>(
        isInternetConnected: true,
        remoteCallback: () async => SuccessState.nil,
        onRemoteSuccess: (_) async {
          deleted = true;
          return const SuccessState(data: true);
        },
      );

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      expect(deleted, isTrue);
    });
  });
}
