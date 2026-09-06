import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/repositories/sectors_repository.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/create_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/delete_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/update_sector_use_case.dart';

import '../../../../../testing/mocks/factories/system_factory.dart';

class MockSectorsRepository extends Mock implements SectorsRepository {}

void main() {
  late MockSectorsRepository mockRepository;
  late GetSectorsUseCase getSectorsUseCase;
  late CreateSectorUseCase createSectorUseCase;
  late UpdateSectorUseCase updateSectorUseCase;
  late DeleteSectorUseCase deleteSectorUseCase;

  setUpAll(() {
    registerFallbackValue(SystemFactory.makeSectorEntity());
  });

  setUp(() {
    mockRepository = MockSectorsRepository();
    getSectorsUseCase = GetSectorsUseCase(sectorsRepository: mockRepository);
    createSectorUseCase = CreateSectorUseCase(
      sectorsRepository: mockRepository,
    );
    updateSectorUseCase = UpdateSectorUseCase(
      sectorsRepository: mockRepository,
    );
    deleteSectorUseCase = DeleteSectorUseCase(
      sectorsRepository: mockRepository,
    );
  });

  group('GetSectorsUseCase Tests', () {
    test('should call getSectors on repository with companyId', () async {
      final tSectors = SystemFactory.makeSectorEntityList();
      final tCompanyId = tSectors.first.companyId;

      when(
        () => mockRepository.getSectors(any()),
      ).thenAnswer((_) async => SuccessState(data: tSectors));

      final result = await getSectorsUseCase(tCompanyId);

      expect(result, isA<SuccessState<List<SectorEntity>>>());
      expect((result as SuccessState<List<SectorEntity>>).data, tSectors);
      verify(() => mockRepository.getSectors(tCompanyId)).called(1);
    });

    test(
      'should return FailureState when repository returns failure',
      () async {
        final tCompanyId = SystemFactory.makeSectorEntity().companyId;
        const tError = 'Error fetching sectors';

        when(
          () => mockRepository.getSectors(any()),
        ).thenAnswer((_) async => FailureState(message: tError));

        final result = await getSectorsUseCase(tCompanyId);

        expect(result, isA<FailureState<List<SectorEntity>>>());
        expect((result as FailureState<List<SectorEntity>>).message, tError);
        verify(() => mockRepository.getSectors(tCompanyId)).called(1);
      },
    );
  });

  group('CreateSectorUseCase Tests', () {
    test('should call createSector on repository with sector entity', () async {
      final tSector = SystemFactory.makeSectorEntity();

      when(
        () => mockRepository.createSector(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await createSectorUseCase(tSector);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, isTrue);
      verify(() => mockRepository.createSector(tSector)).called(1);
    });

    test('should return FailureState when creation fails', () async {
      final tSector = SystemFactory.makeSectorEntity();
      const tError = 'Error creating sector';

      when(
        () => mockRepository.createSector(any()),
      ).thenAnswer((_) async => FailureState(message: tError));

      final result = await createSectorUseCase(tSector);

      expect(result, isA<FailureState<bool>>());
      expect((result as FailureState<bool>).message, tError);
      verify(() => mockRepository.createSector(tSector)).called(1);
    });
  });

  group('UpdateSectorUseCase Tests', () {
    test('should call updateSector on repository with sector entity', () async {
      final tSector = SystemFactory.makeSectorEntity();

      when(
        () => mockRepository.updateSector(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await updateSectorUseCase(tSector);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, isTrue);
      verify(() => mockRepository.updateSector(tSector)).called(1);
    });

    test('should return FailureState when update fails', () async {
      final tSector = SystemFactory.makeSectorEntity();
      const tError = 'Error updating sector';

      when(
        () => mockRepository.updateSector(any()),
      ).thenAnswer((_) async => FailureState(message: tError));

      final result = await updateSectorUseCase(tSector);

      expect(result, isA<FailureState<bool>>());
      expect((result as FailureState<bool>).message, tError);
      verify(() => mockRepository.updateSector(tSector)).called(1);
    });
  });

  group('DeleteSectorUseCase Tests', () {
    test('should call deleteSector on repository with sector id', () async {
      final tSectorId = SystemFactory.makeSectorEntity().id;

      when(
        () => mockRepository.deleteSector(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await deleteSectorUseCase(tSectorId);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, isTrue);
      verify(() => mockRepository.deleteSector(tSectorId)).called(1);
    });

    test('should return FailureState when deletion fails', () async {
      final tSectorId = SystemFactory.makeSectorEntity().id;
      const tError = 'Error deleting sector';

      when(
        () => mockRepository.deleteSector(any()),
      ).thenAnswer((_) async => FailureState(message: tError));

      final result = await deleteSectorUseCase(tSectorId);

      expect(result, isA<FailureState<bool>>());
      expect((result as FailureState<bool>).message, tError);
      verify(() => mockRepository.deleteSector(tSectorId)).called(1);
    });
  });
}
