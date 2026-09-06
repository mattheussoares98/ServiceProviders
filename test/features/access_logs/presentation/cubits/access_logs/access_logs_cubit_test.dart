import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/access_logs/presentation/cubits/access_logs/access_logs_cubit.dart';
import 'package:o_jogo_da_obra/features/access_logs/presentation/cubits/access_logs/access_logs_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/factories/system_factory.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  late MockGetAccessLogsUseCase mockGetAccessLogsUseCase;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
  late MockGetUsersUseCase mockGetUsersUseCase;
  late MockNavigationClient mockNavigationClient;
  late AccessLogsCubitUseCases useCases;

  final tCompanyId = faker.guid.guid();
  final tUsers = UserFactory.makeUserProfileEntityList();
  final tLogs = SystemFactory.makeAccessLogEntityList();

  setUpAll(() {
    registerFallbackValue(SystemFactory.makeGetAccessLogsRequestEntity());
  });

  setUp(() {
    mockGetAccessLogsUseCase = MockGetAccessLogsUseCase();
    mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();
    mockGetUsersUseCase = MockGetUsersUseCase();
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    useCases = AccessLogsCubitUseCases(
      getAccessLogs: mockGetAccessLogsUseCase,
      getActiveCompanyId: mockGetActiveCompanyIdUseCase,
      getUsers: mockGetUsersUseCase,
    );
  });

  tearDown(GetIt.I.reset);

  group('AccessLogsCubit', () {
    test('initial state has empty lists and no filters', () {
      final cubit = AccessLogsCubit(useCases: useCases);
      expect(cubit.state.logs, isEmpty);
      expect(cubit.state.users, isEmpty);
      expect(cubit.state.startDate, isNull);
      expect(cubit.state.endDate, isNull);
      expect(cubit.state.selectedUserId, isNull);
      expect(cubit.state.hasReachedMax, isFalse);
      expect(cubit.state.page, 0);
    });

    blocTest<AccessLogsCubit, AccessLogsState>(
      'loadInitialData emits running and success on valid data fetch',
      setUp: () {
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn(tCompanyId);
        when(
          () => mockGetUsersUseCase.call(tCompanyId),
        ).thenAnswer((_) async => SuccessState(data: tUsers));
        when(
          () => mockGetAccessLogsUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: tLogs));
      },
      build: () => AccessLogsCubit(useCases: useCases),
      act: (cubit) => cubit.loadInitialData(),
      expect: () => [
        isA<AccessLogsState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'running load status',
          SectionStatus.running,
        ),
        isA<AccessLogsState>()
            .having((s) => s.logs, 'logs', tLogs)
            .having((s) => s.users, 'users', tUsers)
            .having((s) => s.hasReachedMax, 'hasReachedMax', isTrue)
            .having(
              (s) => s.sections[BaseSections.load]?.status,
              'success load status',
              SectionStatus.success,
            ),
      ],
      verify: (_) {
        verify(() => mockGetActiveCompanyIdUseCase.call()).called(1);
        verify(() => mockGetUsersUseCase.call(tCompanyId)).called(1);
        verify(() => mockGetAccessLogsUseCase.call(any())).called(1);
      },
    );

    blocTest<AccessLogsCubit, AccessLogsState>(
      'loadInitialData emits running and success with empty state when companyId is empty',
      setUp: () {
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn('');
      },
      build: () => AccessLogsCubit(useCases: useCases),
      act: (cubit) => cubit.loadInitialData(),
      expect: () => [
        isA<AccessLogsState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'running load status',
          SectionStatus.running,
        ),
        isA<AccessLogsState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'success load status',
          SectionStatus.success,
        ),
      ],
    );

    blocTest<AccessLogsCubit, AccessLogsState>(
      'loadInitialData emits running and error when getAccessLogs fails',
      setUp: () {
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn(tCompanyId);
        when(
          () => mockGetUsersUseCase.call(tCompanyId),
        ).thenAnswer((_) async => SuccessState(data: tUsers));
        when(() => mockGetAccessLogsUseCase.call(any())).thenAnswer(
          (_) async =>
              FailureState(message: faker.lorem.sentence(), statusCode: 500),
        );
      },
      build: () => AccessLogsCubit(useCases: useCases),
      act: (cubit) => cubit.loadInitialData(),
      expect: () => [
        isA<AccessLogsState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'running load status',
          SectionStatus.running,
        ),
        isA<AccessLogsState>()
            .having((s) => s.users, 'users', tUsers)
            .having(
              (s) => s.sections[BaseSections.load]?.status,
              'error load status',
              SectionStatus.error,
            ),
      ],
    );

    blocTest<AccessLogsCubit, AccessLogsState>(
      'setDateRange updates date range filter and reloads data',
      setUp: () {
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn(tCompanyId);
        when(
          () => mockGetUsersUseCase.call(tCompanyId),
        ).thenAnswer((_) async => SuccessState(data: tUsers));
        when(
          () => mockGetAccessLogsUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: tLogs));
      },
      build: () => AccessLogsCubit(useCases: useCases),
      act: (cubit) {
        final start = DateTime(2026, 9);
        final end = DateTime(2026, 9, 5);
        cubit.setDateRange(startDate: start, endDate: end);
      },
      expect: () => [
        isA<AccessLogsState>()
            .having((s) => s.startDate, 'startDate', DateTime(2026, 9))
            .having((s) => s.endDate, 'endDate', DateTime(2026, 9, 5)),
        isA<AccessLogsState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'running load status',
          SectionStatus.running,
        ),
        isA<AccessLogsState>()
            .having((s) => s.logs, 'logs', tLogs)
            .having((s) => s.startDate, 'startDate', DateTime(2026, 9))
            .having((s) => s.endDate, 'endDate', DateTime(2026, 9, 5))
            .having(
              (s) => s.sections[BaseSections.load]?.status,
              'success load status',
              SectionStatus.success,
            ),
      ],
    );

    blocTest<AccessLogsCubit, AccessLogsState>(
      'setSelectedUser updates selected user filter and reloads data',
      setUp: () {
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn(tCompanyId);
        when(
          () => mockGetUsersUseCase.call(tCompanyId),
        ).thenAnswer((_) async => SuccessState(data: tUsers));
        when(
          () => mockGetAccessLogsUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: tLogs));
      },
      build: () => AccessLogsCubit(useCases: useCases),
      act: (cubit) => cubit.setSelectedUser('user-123'),
      expect: () => [
        isA<AccessLogsState>().having(
          (s) => s.selectedUserId,
          'selectedUserId',
          'user-123',
        ),
        isA<AccessLogsState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'running load status',
          SectionStatus.running,
        ),
        isA<AccessLogsState>()
            .having((s) => s.logs, 'logs', tLogs)
            .having((s) => s.selectedUserId, 'selectedUserId', 'user-123')
            .having(
              (s) => s.sections[BaseSections.load]?.status,
              'success load status',
              SectionStatus.success,
            ),
      ],
    );

    blocTest<AccessLogsCubit, AccessLogsState>(
      'clearFilters resets date and user filters and reloads',
      seed: () => AccessLogsState(
        startDate: DateTime(2026, 9),
        endDate: DateTime(2026, 9, 5),
        selectedUserId: 'user-123',
      ),
      setUp: () {
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn(tCompanyId);
        when(
          () => mockGetUsersUseCase.call(tCompanyId),
        ).thenAnswer((_) async => SuccessState(data: tUsers));
        when(
          () => mockGetAccessLogsUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: tLogs));
      },
      build: () => AccessLogsCubit(useCases: useCases),
      act: (cubit) => cubit.clearFilters(),
      expect: () => [
        isA<AccessLogsState>()
            .having((s) => s.startDate, 'startDate', isNull)
            .having((s) => s.endDate, 'endDate', isNull)
            .having((s) => s.selectedUserId, 'selectedUserId', isNull),
        isA<AccessLogsState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'running load status',
          SectionStatus.running,
        ),
        isA<AccessLogsState>()
            .having((s) => s.logs, 'logs', tLogs)
            .having(
              (s) => s.sections[BaseSections.load]?.status,
              'success load status',
              SectionStatus.success,
            ),
      ],
    );
  });
}
