import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/repositories/sectors_repository.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/create_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';

class MockSectorsRepository extends Mock implements SectorsRepository {}

void main() {
  late MockSectorsRepository mockRepository;
  late GetSectorsUseCase getSectorsUseCase;
  late CreateSectorUseCase createSectorUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeSectorEntity());
  });

  setUp(() {
    mockRepository = MockSectorsRepository();
    getSectorsUseCase = GetSectorsUseCase(sectorsRepository: mockRepository);
    createSectorUseCase = CreateSectorUseCase(
      sectorsRepository: mockRepository,
    );
  });

  group('GetSectorsUseCase Tests', () {
    test('should call getSectors on repository with companyId', () async {
      final tSectors = EntityFactory.makeSectorEntityList();
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
        final tCompanyId = EntityFactory.makeSectorEntity().companyId;
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
      final tSector = EntityFactory.makeSectorEntity();

      when(
        () => mockRepository.createSector(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await createSectorUseCase(tSector);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, isTrue);
      verify(() => mockRepository.createSector(tSector)).called(1);
    });

    test('should return FailureState when creation fails', () async {
      final tSector = EntityFactory.makeSectorEntity();
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
}
