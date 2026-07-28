import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/create_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetSectorsUseCase extends Mock implements GetSectorsUseCase {}

class MockCreateSectorUseCase extends Mock implements CreateSectorUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetSectorsUseCase mockGetSectors;
  late MockCreateSectorUseCase mockCreateSector;
  late MockNavigationClient mockNavigationClient;
  late SectorsCubit cubit;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeSectorEntity());
  });

  setUp(() {
    mockGetSectors = MockGetSectorsUseCase();
    mockCreateSector = MockCreateSectorUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    final useCases = SectorsCubitUseCases(
      getSectors: mockGetSectors,
      createSector: mockCreateSector,
    );

    cubit = SectorsCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('SectorsCubit Tests', () {
    group('loadSectors', () {
      blocTest<SectorsCubit, SectorsState>(
        'should emit loading and loaded state when fetching sectors succeeds',
        build: () {
          final tSectors = EntityFactory.makeSectorEntityList();
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tSectors));
          return cubit;
        },
        act: (cubit) => cubit.loadSectors('company-123'),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<SectorsState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.sectors, 'sectors', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetSectors.call('company-123')).called(1);
        },
      );

      blocTest<SectorsCubit, SectorsState>(
        'should emit loading and loadingError when fetching sectors fails',
        build: () {
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));
          return cubit;
        },
        act: (cubit) => cubit.loadSectors('company-123'),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<SectorsState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Error'),
        ],
      );
    });

    group('selectSector', () {
      final tSectors = EntityFactory.makeSectorEntityList();
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
      final tSector = EntityFactory.makeSectorEntity();

      blocTest<SectorsCubit, SectorsState>(
        'should emit saving and loaded when creating sector succeeds',
        build: () {
          when(
            () => mockCreateSector.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tSector]));
          return cubit;
        },
        act: (cubit) => cubit.saveSector(tSector),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<SectorsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<SectorsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateSector.call(tSector)).called(1);
        },
      );

      blocTest<SectorsCubit, SectorsState>(
        'should emit saving and savingError when creation fails',
        build: () {
          when(
            () => mockCreateSector.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Save failed'));
          return cubit;
        },
        act: (cubit) => cubit.saveSector(tSector),
        expect: () => [
          isA<SectorsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<SectorsState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Save failed'),
        ],
      );
    });
  });
}
