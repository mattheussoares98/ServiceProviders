import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/create_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/delete_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/get_sla_policies_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/get_sla_policy_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/update_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/watch_sla_policies_realtime_use_case.dart';

import '../../../../../testing/mocks/factories/system_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockSlaRepository mockSlaRepository;

  late GetSlaPoliciesUseCase getSlaPoliciesUseCase;
  late GetSlaPolicyByIdUseCase getSlaPolicyByIdUseCase;
  late CreateSlaPolicyUseCase createSlaPolicyUseCase;
  late UpdateSlaPolicyUseCase updateSlaPolicyUseCase;
  late DeleteSlaPolicyUseCase deleteSlaPolicyUseCase;
  late WatchSlaPoliciesRealtimeUseCase watchSlaPoliciesRealtimeUseCase;

  setUpAll(() {
    registerFallbackValue(SystemFactory.makeSlaPolicyEntity());
  });

  setUp(() {
    mockSlaRepository = MockSlaRepository();

    getSlaPoliciesUseCase = GetSlaPoliciesUseCase(
      slaRepository: mockSlaRepository,
    );
    getSlaPolicyByIdUseCase = GetSlaPolicyByIdUseCase(
      slaRepository: mockSlaRepository,
    );
    createSlaPolicyUseCase = CreateSlaPolicyUseCase(
      slaRepository: mockSlaRepository,
    );
    updateSlaPolicyUseCase = UpdateSlaPolicyUseCase(
      slaRepository: mockSlaRepository,
    );
    deleteSlaPolicyUseCase = DeleteSlaPolicyUseCase(
      slaRepository: mockSlaRepository,
    );
    watchSlaPoliciesRealtimeUseCase = WatchSlaPoliciesRealtimeUseCase(
      slaRepository: mockSlaRepository,
    );
  });

  group('GetSlaPoliciesUseCase', () {
    final tCompanyId = faker.guid.guid();
    final tSlaPolicies = SystemFactory.makeSlaPolicyEntityList();

    test('should return list of SLA policies on success', () async {
      when(
        () => mockSlaRepository.getSlaPolicies(any()),
      ).thenAnswer((_) async => SuccessState(data: tSlaPolicies));

      final result = await getSlaPoliciesUseCase(tCompanyId);

      expect(result, isA<SuccessState<List<dynamic>>>());
      expect(result.data, tSlaPolicies);
      verify(() => mockSlaRepository.getSlaPolicies(tCompanyId)).called(1);
    });
  });

  group('GetSlaPolicyByIdUseCase', () {
    final tId = faker.guid.guid();
    final tSlaPolicy = SystemFactory.makeSlaPolicyEntity();

    test('should return SLA policy on success', () async {
      when(
        () => mockSlaRepository.getSlaPolicyById(any()),
      ).thenAnswer((_) async => SuccessState(data: tSlaPolicy));

      final result = await getSlaPolicyByIdUseCase(tId);

      expect(result, isA<SuccessState<dynamic>>());
      expect(result.data, tSlaPolicy);
      verify(() => mockSlaRepository.getSlaPolicyById(tId)).called(1);
    });
  });

  group('CreateSlaPolicyUseCase', () {
    final tSlaPolicy = SystemFactory.makeSlaPolicyEntity();

    test('should return true on success', () async {
      when(
        () => mockSlaRepository.createSlaPolicy(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await createSlaPolicyUseCase(tSlaPolicy);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockSlaRepository.createSlaPolicy(tSlaPolicy)).called(1);
    });
  });

  group('UpdateSlaPolicyUseCase', () {
    final tSlaPolicy = SystemFactory.makeSlaPolicyEntity();

    test('should return true on success', () async {
      when(
        () => mockSlaRepository.updateSlaPolicy(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await updateSlaPolicyUseCase(tSlaPolicy);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockSlaRepository.updateSlaPolicy(tSlaPolicy)).called(1);
    });
  });

  group('DeleteSlaPolicyUseCase', () {
    final tId = faker.guid.guid();

    test('should return true on success', () async {
      when(
        () => mockSlaRepository.deleteSlaPolicy(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await deleteSlaPolicyUseCase(tId);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockSlaRepository.deleteSlaPolicy(tId)).called(1);
    });
  });

  group('WatchSlaPoliciesRealtimeUseCase', () {
    final tSlaPolicy = SystemFactory.makeSlaPolicyEntity();
    final tCompanyId = faker.guid.guid();

    test('should return stream from repository', () {
      final event = SystemFactory.makeRealtimeEvent<SlaPolicyEntity>(
        entity: tSlaPolicy,
      );
      when(
        () => mockSlaRepository.watchSlaPoliciesRealtime(
          companyId: any(named: 'companyId'),
        ),
      ).thenAnswer((_) => Stream.value(event));

      final result = watchSlaPoliciesRealtimeUseCase(companyId: tCompanyId);

      expect(result, emits(event));
      verify(
        () => mockSlaRepository.watchSlaPoliciesRealtime(companyId: tCompanyId),
      ).called(1);
    });
  });
}
