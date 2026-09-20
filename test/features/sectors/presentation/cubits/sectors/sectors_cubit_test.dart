import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/factories/system_factory.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetSectorsUseCase mockGetSectors;
  late MockCreateSectorUseCase mockCreateSector;
  late MockUpdateSectorUseCase mockUpdateSector;
  late MockDeleteSectorUseCase mockDeleteSector;
  late MockWatchSectorsRealtimeUseCase mockWatchSectorsRealtime;
  late MockNavigationClient mockNavigationClient;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
  late UserProfileEntity tUserProfile;
  late SectorsCubit cubit;

  setUpAll(() {
    registerFallbackValue(SystemFactory.makeSectorEntity());
    registerFallbackValue(CreateUpdateSectorRoute());
  });

  setUp(() {
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetSectors = MockGetSectorsUseCase();
    mockCreateSector = MockCreateSectorUseCase();
    mockUpdateSector = MockUpdateSectorUseCase();
    mockDeleteSector = MockDeleteSectorUseCase();
    mockWatchSectorsRealtime = MockWatchSectorsRealtimeUseCase();
    mockNavigationClient = MockNavigationClient();
    mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = UserFactory.makeUserProfileEntity();
    when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);
    when(
      () => mockGetActiveCompanyIdUseCase.call(),
    ).thenReturn(tUserProfile.companyId);
    when(
      () => mockWatchSectorsRealtime(companyId: any(named: 'companyId')),
    ).thenAnswer((_) => const Stream.empty());

    final useCases = SectorsCubitUseCases(
      getSectors: mockGetSectors,
      createSector: mockCreateSector,
      updateSector: mockUpdateSector,
      deleteSector: mockDeleteSector,
      getActiveCompanyId: mockGetActiveCompanyIdUseCase,
      watchSectorsRealtime: mockWatchSectorsRealtime,
    );

    cubit = SectorsCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('SectorsCubit Tests', () {
    final tSector = SystemFactory.makeSectorEntity();
    final tSectors = SystemFactory.makeSectorEntityList();

    group('loadSectors', () {
      blocTest<SectorsCubit, SectorsState>(
        'should emit loading and loaded when fetching sectors succeeds',
        build: () {
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tSectors));
          when(
            () => mockGetActiveCompanyIdUseCase.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.loadSectors(),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<SectorsState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.sectors, 'sectors', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetSectors.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<SectorsCubit, SectorsState>(
        'should emit loading and loadingError when fetching sectors fails',
        build: () {
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));
          when(
            () => mockGetActiveCompanyIdUseCase.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.loadSectors(),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<SectorsState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.error('Error'),
          ),
        ],
      );
    });

    group('selectSector', () {
      final targetSector = tSectors.first;

      blocTest<SectorsCubit, SectorsState>(
        'should update selectedSector when sector id is found',
        seed: () => SectorsState(sectors: tSectors),
        build: () => cubit,
        act: (cubit) => cubit.selectSector(targetSector.id),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.selectedSector,
            'selectedSector',
            targetSector,
          ),
        ],
      );

      blocTest<SectorsCubit, SectorsState>(
        'should clear selectedSector when id is null',
        seed: () =>
            SectorsState(sectors: tSectors, selectedSector: targetSector),
        build: () => cubit,
        act: (cubit) => cubit.selectSector(null),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.selectedSector,
            'selectedSector',
            isNull,
          ),
        ],
      );
    });

    group('saveSector', () {
      blocTest<SectorsCubit, SectorsState>(
        'should emit saving and loaded section states, and reload sectors when creating sector succeeds',
        build: () {
          when(
            () => mockCreateSector.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tSector]));
          when(
            () => mockGetActiveCompanyIdUseCase.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.saveSector(name: tSector.name),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            const SectionState.running(),
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            const SectionState.success(),
          ),
          isA<SectorsState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.sectors, 'sectors', [tSector]),
        ],
        verify: (_) {
          verify(() => mockCreateSector.call(any())).called(1);
          verify(() => mockGetSectors.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<SectorsCubit, SectorsState>(
        'should emit saving and loaded section states when updating sector succeeds',
        seed: () => SectorsState(sectors: [tSector]),
        build: () {
          when(
            () => mockUpdateSector.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tSector]));
          when(
            () => mockGetActiveCompanyIdUseCase.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.saveSector(id: tSector.id, name: tSector.name),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            const SectionState.running(),
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            const SectionState.success(),
          ),
          isA<SectorsState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.sectors, 'sectors', [tSector]),
        ],
        verify: (_) {
          verify(() => mockUpdateSector.call(any())).called(1);
          verify(() => mockGetSectors.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<SectorsCubit, SectorsState>(
        'should emit saving and savingError section states when creation fails',
        build: () {
          when(
            () => mockCreateSector.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Save failed'));
          when(
            () => mockGetActiveCompanyIdUseCase.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.saveSector(name: tSector.name),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            const SectionState.running(),
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            const SectionState.error(),
          ),
        ],
        verify: (_) {
          verify(() => mockCreateSector.call(any())).called(1);
          verifyNever(() => mockGetSectors.call(any()));
        },
      );

      blocTest<SectorsCubit, SectorsState>(
        'should reject whitespace-only name without calling createSector usecase',
        build: () => cubit,
        act: (cubit) async {
          final result = await cubit.saveSector(
            id: null,
            name: '   ',
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            isA<SectionState>().having(
              (s) => s.status,
              'status',
              SectionStatus.error,
            ),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockCreateSector.call(any()));
        },
      );

      blocTest<SectorsCubit, SectorsState>(
        'should reject creating sector with duplicate name already existing in state',
        seed: () => cubit.state.copyWith(
          sectors: [tSector],
        ),
        build: () => cubit,
        act: (cubit) async {
          final result = await cubit.saveSector(
            id: null,
            name: tSector.name.toUpperCase(),
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            isA<SectionState>().having(
              (s) => s.status,
              'status',
              SectionStatus.error,
            ),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockCreateSector.call(any()));
        },
      );
    });

    group('deleteSector', () {
      blocTest<SectorsCubit, SectorsState>(
        'should emit deleting and loaded section states when deleting sector succeeds',
        build: () {
          when(
            () => mockDeleteSector.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetActiveCompanyIdUseCase.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.deleteSector(tSector.id),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.delete],
            'sections[delete]',
            const SectionState.running(),
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.delete],
            'sections[delete]',
            const SectionState.success(),
          ),
          isA<SectorsState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.sectors, 'sectors', isEmpty),
        ],
        verify: (_) {
          verify(() => mockDeleteSector.call(tSector.id)).called(1);
          verify(() => mockGetSectors.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<SectorsCubit, SectorsState>(
        'should emit deleting and deletingError section states when deleting sector fails',
        build: () {
          when(
            () => mockDeleteSector.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Delete failed'));
          when(
            () => mockGetActiveCompanyIdUseCase.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.deleteSector(tSector.id),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.delete],
            'sections[delete]',
            const SectionState.running(),
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.delete],
            'sections[delete]',
            const SectionState.error(),
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteSector.call(tSector.id)).called(1);
          verifyNever(() => mockGetSectors.call(any()));
        },
      );
    });

    group('navigateToCreateUpdateSector', () {
      blocTest<SectorsCubit, SectorsState>(
        'should push route with sector and reload sectors on completion',
        build: () {
          when(
            () => mockNavigationClient.pushRoute<CreateUpdateSectorRouteArgs>(
              any(),
            ),
          ).thenAnswer((_) async => null);
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tSector]));
          when(
            () => mockGetActiveCompanyIdUseCase.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.navigateToCreateUpdateSector(sector: tSector),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.success(),
          ),
        ],
        verify: (_) {
          verify(
            () => mockNavigationClient.pushRoute<CreateUpdateSectorRouteArgs>(
              any(),
            ),
          ).called(1);
          verify(() => mockGetSectors.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<SectorsCubit, SectorsState>(
        'should push route without sector and reload sectors on completion',
        build: () {
          when(
            () => mockNavigationClient.pushRoute<CreateUpdateSectorRouteArgs>(
              any(),
            ),
          ).thenAnswer((_) async => null);
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tSector]));
          when(
            () => mockGetActiveCompanyIdUseCase.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.navigateToCreateUpdateSector(),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.success(),
          ),
        ],
        verify: (_) {
          verify(
            () => mockNavigationClient.pushRoute<CreateUpdateSectorRouteArgs>(
              any(),
            ),
          ).called(1);
          verify(() => mockGetSectors.call(tUserProfile.companyId)).called(1);
        },
      );
    });

    group('realtime events', () {
      test('inserts new sector into state on insert event', () async {
        final streamController =
            StreamController<RealtimeEvent<SectorEntity>>();
        when(
          () => mockWatchSectorsRealtime(companyId: any(named: 'companyId')),
        ).thenAnswer((_) => streamController.stream);

        final useCases = SectorsCubitUseCases(
          getSectors: mockGetSectors,
          createSector: mockCreateSector,
          updateSector: mockUpdateSector,
          deleteSector: mockDeleteSector,
          getActiveCompanyId: mockGetActiveCompanyIdUseCase,
          watchSectorsRealtime: mockWatchSectorsRealtime,
        );
        final c = SectorsCubit(useCases: useCases);

        final newSector = SystemFactory.makeSectorEntity();
        streamController.add(
          RealtimeEvent(
            eventType: RealtimeEventType.insert,
            id: newSector.id,
            entity: newSector,
          ),
        );

        await pumpEventQueue();

        expect(c.state.sectors, contains(newSector));
        await c.close();
        await streamController.close();
      });

      test('updates existing sector on update event', () async {
        final streamController =
            StreamController<RealtimeEvent<SectorEntity>>();
        when(
          () => mockWatchSectorsRealtime(companyId: any(named: 'companyId')),
        ).thenAnswer((_) => streamController.stream);

        final useCases = SectorsCubitUseCases(
          getSectors: mockGetSectors,
          createSector: mockCreateSector,
          updateSector: mockUpdateSector,
          deleteSector: mockDeleteSector,
          getActiveCompanyId: mockGetActiveCompanyIdUseCase,
          watchSectorsRealtime: mockWatchSectorsRealtime,
        );
        final c = SectorsCubit(useCases: useCases);

        final initialSector = SystemFactory.makeSectorEntity();
        c.emit(c.state.copyWith(sectors: [initialSector]));

        final updatedSector = initialSector.copyWith(name: 'Updated Sector');
        streamController.add(
          RealtimeEvent(
            eventType: RealtimeEventType.update,
            id: updatedSector.id,
            entity: updatedSector,
          ),
        );

        await pumpEventQueue();

        expect(c.state.sectors.first.name, 'Updated Sector');
        await c.close();
        await streamController.close();
      });

      test('removes sector on delete or soft-delete event', () async {
        final streamController =
            StreamController<RealtimeEvent<SectorEntity>>();
        when(
          () => mockWatchSectorsRealtime(companyId: any(named: 'companyId')),
        ).thenAnswer((_) => streamController.stream);

        final useCases = SectorsCubitUseCases(
          getSectors: mockGetSectors,
          createSector: mockCreateSector,
          updateSector: mockUpdateSector,
          deleteSector: mockDeleteSector,
          getActiveCompanyId: mockGetActiveCompanyIdUseCase,
          watchSectorsRealtime: mockWatchSectorsRealtime,
        );
        final c = SectorsCubit(useCases: useCases);

        final sector1 = SystemFactory.makeSectorEntity();
        final sector2 = SystemFactory.makeSectorEntity();
        c.emit(c.state.copyWith(sectors: [sector1, sector2]));

        streamController.add(
          RealtimeEvent(
            eventType: RealtimeEventType.delete,
            id: sector1.id,
            entity: sector1,
          ),
        );

        await pumpEventQueue();

        expect(c.state.sectors, isNot(contains(sector1)));
        expect(c.state.sectors, contains(sector2));

        final softDeleted = sector2.copyWith(deletedAt: DateTime.now().toUtc());
        streamController.add(
          RealtimeEvent(
            eventType: RealtimeEventType.update,
            id: softDeleted.id,
            entity: softDeleted,
          ),
        );

        await pumpEventQueue();

        expect(c.state.sectors, isEmpty);
        await c.close();
        await streamController.close();
      });
    });
  });
}
