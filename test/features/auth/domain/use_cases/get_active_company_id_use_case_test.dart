import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockSessionRepository mockSessionRepository;
  late GetActiveCompanyIdUseCase useCase;

  setUp(() {
    mockSessionRepository = MockSessionRepository();
    useCase = GetActiveCompanyIdUseCase(
      sessionRepository: mockSessionRepository,
    );
  });

  group('GetActiveCompanyIdUseCase', () {
    test('returns user companyId when app mode is internal', () {
      final userCompanyId = faker.guid.guid();
      final userProfile = EntityFactory.makeUserProfileEntity().copyWith(
        companyId: userCompanyId,
      );
      final userData = EntityFactory.makeUserDataEntity().copyWith(
        user: userProfile,
      );

      when(
        () => mockSessionRepository.getSelectedMode(),
      ).thenReturn(AppMode.internal.name);
      when(() => mockSessionRepository.userData).thenReturn(userData);

      final result = useCase.call();

      expect(result, equals(userCompanyId));
      verify(() => mockSessionRepository.getSelectedMode()).called(1);
      verify(() => mockSessionRepository.userData).called(1);
    });

    test(
      'returns selected companyId when app mode is provider and selectedCompanyId is set',
      () {
        final selectedCompanyId = faker.guid.guid();

        when(
          () => mockSessionRepository.getSelectedMode(),
        ).thenReturn(AppMode.provider.name);
        when(
          () => mockSessionRepository.getSelectedCompanyId(),
        ).thenReturn(selectedCompanyId);

        final result = useCase.call();

        expect(result, equals(selectedCompanyId));
        verify(() => mockSessionRepository.getSelectedMode()).called(1);
        verify(() => mockSessionRepository.getSelectedCompanyId()).called(1);
        verifyNever(() => mockSessionRepository.userData);
      },
    );

    test(
      'falls back to user companyId when app mode is provider but selectedCompanyId is null',
      () {
        final userCompanyId = faker.guid.guid();
        final userProfile = EntityFactory.makeUserProfileEntity().copyWith(
          companyId: userCompanyId,
        );
        final userData = EntityFactory.makeUserDataEntity().copyWith(
          user: userProfile,
        );

        when(
          () => mockSessionRepository.getSelectedMode(),
        ).thenReturn(AppMode.provider.name);
        when(
          () => mockSessionRepository.getSelectedCompanyId(),
        ).thenReturn(null);
        when(() => mockSessionRepository.userData).thenReturn(userData);

        final result = useCase.call();

        expect(result, equals(userCompanyId));
        verify(() => mockSessionRepository.getSelectedMode()).called(1);
        verify(() => mockSessionRepository.getSelectedCompanyId()).called(1);
        verify(() => mockSessionRepository.userData).called(1);
      },
    );
  });
}
