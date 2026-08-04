import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/sla_policy_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/repositories/sla_repository_impl.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/sla_policy_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockSlaRemoteDataSource mockRemoteDataSource;
  late MockSlaLocalDataSource mockLocalDataSource;
  late SlaRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      SlaPolicyModel.fromEntity(EntityFactory.makeSlaPolicyEntity()),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockSlaRemoteDataSource();
    mockLocalDataSource = MockSlaLocalDataSource();
    repository = SlaRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tSlaPolicyEntity = EntityFactory.makeSlaPolicyEntity();
  final tSlaPolicyModel = SlaPolicyModel.fromEntity(tSlaPolicyEntity);

  group('getSlaPolicies', () {
    test(
      'should fetch remote list and cache it locally when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getSlaPolicies(any()),
        ).thenAnswer((_) async => SuccessState(data: [tSlaPolicyModel]));
        when(
          () => mockLocalDataSource.saveSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getSlaPolicies(
          tSlaPolicyEntity.companyId,
        );

        expect(result, isA<SuccessState<List<SlaPolicyEntity>>>());
        expect(
          (result as SuccessState<List<SlaPolicyEntity>>).data!.first.id,
          tSlaPolicyEntity.id,
        );
        verify(
          () => mockRemoteDataSource.getSlaPolicies(tSlaPolicyEntity.companyId),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveSlaPolicy(tSlaPolicyModel),
        ).called(1);
      },
    );

    test('should fetch local list when internet is disconnected', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getSlaPolicies(any()),
      ).thenAnswer((_) async => SuccessState(data: [tSlaPolicyModel]));

      final result = await repository.getSlaPolicies(
        tSlaPolicyEntity.companyId,
      );

      expect(result, isA<SuccessState<List<SlaPolicyEntity>>>());
      expect(
        (result as SuccessState<List<SlaPolicyEntity>>).data!.first.id,
        tSlaPolicyEntity.id,
      );
      verifyNever(() => mockRemoteDataSource.getSlaPolicies(any()));
      verify(
        () => mockLocalDataSource.getSlaPolicies(tSlaPolicyEntity.companyId),
      ).called(1);
    });
  });

  group('getSlaPolicyById', () {
    test(
      'should fetch remote policy and cache it locally when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getSlaPolicyById(any()),
        ).thenAnswer((_) async => SuccessState(data: tSlaPolicyModel));
        when(
          () => mockLocalDataSource.saveSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getSlaPolicyById(tSlaPolicyEntity.id);

        expect(result, isA<SuccessState<SlaPolicyEntity>>());
        expect(
          (result as SuccessState<SlaPolicyEntity>).data!.id,
          tSlaPolicyEntity.id,
        );
        verify(
          () => mockRemoteDataSource.getSlaPolicyById(tSlaPolicyEntity.id),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveSlaPolicy(tSlaPolicyModel),
        ).called(1);
      },
    );
  });

  group('createSlaPolicy', () {
    test(
      'should create policy remotely and locally when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.createSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.saveSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createSlaPolicy(tSlaPolicyEntity);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockRemoteDataSource.createSlaPolicy(
            SlaPolicyModel.fromEntity(tSlaPolicyEntity),
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveSlaPolicy(
            SlaPolicyModel.fromEntity(tSlaPolicyEntity),
          ),
        ).called(1);
      },
    );

    test(
      'should create policy locally only when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createSlaPolicy(tSlaPolicyEntity);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verifyNever(() => mockRemoteDataSource.createSlaPolicy(any()));
        verify(
          () => mockLocalDataSource.saveSlaPolicy(tSlaPolicyModel),
        ).called(1);
      },
    );
  });

  group('updateSlaPolicy', () {
    test(
      'should update policy remotely and locally when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.updateSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.saveSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.updateSlaPolicy(tSlaPolicyEntity);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockRemoteDataSource.updateSlaPolicy(tSlaPolicyModel),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveSlaPolicy(tSlaPolicyModel),
        ).called(1);
      },
    );

    test(
      'should update policy locally only when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.updateSlaPolicy(tSlaPolicyEntity);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verifyNever(() => mockRemoteDataSource.updateSlaPolicy(any()));
        verify(
          () => mockLocalDataSource.saveSlaPolicy(tSlaPolicyModel),
        ).called(1);
      },
    );
  });

  group('deleteSlaPolicy', () {
    test(
      'should delete policy remotely and locally when internet is connected and remote succeeds',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.deleteSlaPolicy(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        when(
          () => mockLocalDataSource.deleteSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteSlaPolicy(tSlaPolicyEntity.id);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockRemoteDataSource.deleteSlaPolicy(tSlaPolicyEntity.id),
        ).called(1);
        verify(
          () => mockLocalDataSource.deleteSlaPolicy(tSlaPolicyEntity.id),
        ).called(1);
      },
    );

    test(
      'should return failure and not delete locally when remote fails',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.deleteSlaPolicy(any()),
        ).thenAnswer((_) async => FailureState(message: 'Failed to delete'));

        final result = await repository.deleteSlaPolicy(tSlaPolicyEntity.id);

        expect(result, isA<FailureState<bool>>());
        verify(
          () => mockRemoteDataSource.deleteSlaPolicy(tSlaPolicyEntity.id),
        ).called(1);
        verifyNever(() => mockLocalDataSource.deleteSlaPolicy(any()));
      },
    );

    test(
      'should delete policy locally only when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.deleteSlaPolicy(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteSlaPolicy(tSlaPolicyEntity.id);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verifyNever(() => mockRemoteDataSource.deleteSlaPolicy(any()));
        verify(
          () => mockLocalDataSource.deleteSlaPolicy(tSlaPolicyEntity.id),
        ).called(1);
      },
    );
  });
}
