import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetSectorsUseCase mockGetSectors;
  late MockCreateSectorUseCase mockCreateSector;
  late MockUpdateSectorUseCase mockUpdateSector;
  late MockDeleteSectorUseCase mockDeleteSector;
  late MockNavigationClient mockNavigationClient;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
  late UserProfileEntity tUserProfile;
  late SectorsCubit cubit;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeSectorEntity());
    registerFallbackValue(CreateUpdateSectorRoute());
  });

  setUp(() {
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetSectors = MockGetSectorsUseCase();
    mockCreateSector = MockCreateSectorUseCase();
    mockUpdateSector = MockUpdateSectorUseCase();
    mockDeleteSector = MockDeleteSectorUseCase();
    mockNavigationClient = MockNavigationClient();
    mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();
    when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);

    final useCases = SectorsCubitUseCases(
      getSectors: mockGetSectors,
      createSector: mockCreateSector,
      updateSector: mockUpdateSector,
      deleteSector: mockDeleteSector,
      getActiveCompanyId: mockGetActiveCompanyIdUseCase,
    );

    cubit = SectorsCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('SectorsCubit Tests', () {
    final tSector = EntityFactory.makeSectorEntity();
    final tSectors = EntityFactory.makeSectorEntityList();

    group('loadSectors', () {
      blocTest<SectorsCubit, SectorsState>(
        'should emit loading and loaded state when fetching sectors succeeds',
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
            (s) => s.status,
            'status',
            DataStatus.loading,
          ),
          isA<SectorsState>()
              .having((s) => s.status, 'status', DataStatus.loaded)
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
            (s) => s.status,
            'status',
            DataStatus.loading,
          ),
          isA<SectorsState>()
              .having((s) => s.status, 'status', DataStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Error'),
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
            SectionStatus.running,
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            SectionStatus.success,
          ),
          isA<SectorsState>()
              .having((s) => s.status, 'status', DataStatus.loaded)
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
            SectionStatus.running,
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            SectionStatus.success,
          ),
          isA<SectorsState>()
              .having((s) => s.status, 'status', DataStatus.loaded)
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
            SectionStatus.running,
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.save],
            'sections[save]',
            SectionStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateSector.call(any())).called(1);
          verifyNever(() => mockGetSectors.call(any()));
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
            SectionStatus.running,
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.delete],
            'sections[delete]',
            SectionStatus.success,
          ),
          isA<SectorsState>()
              .having((s) => s.status, 'status', DataStatus.loaded)
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
            SectionStatus.running,
          ),
          isA<SectorsState>().having(
            (s) => s.sections[SectorsSections.delete],
            'sections[delete]',
            SectionStatus.error,
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
            (s) => s.status,
            'status',
            DataStatus.loaded,
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
            (s) => s.status,
            'status',
            DataStatus.loaded,
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
  });
}
