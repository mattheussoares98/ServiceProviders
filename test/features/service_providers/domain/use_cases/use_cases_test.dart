import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/accept_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/delete_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_invitations_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_company_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/send_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_profile_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockServiceProviderRepository mockServiceProviderRepository;

  late CreateServiceProviderCompanyUseCase createServiceProviderCompanyUseCase;
  late UpdateServiceProviderCompanyUseCase updateServiceProviderCompanyUseCase;
  late CreateServiceProviderProfileUseCase createServiceProviderProfileUseCase;
  late UpdateServiceProviderProfileUseCase updateServiceProviderProfileUseCase;
  late GetServiceProviderInvitationsUseCase
  getServiceProviderInvitationsUseCase;
  late SendServiceProviderInvitationUseCase
  sendServiceProviderInvitationUseCase;
  late DeleteServiceProviderInvitationUseCase
  deleteServiceProviderInvitationUseCase;
  late AcceptServiceProviderInvitationUseCase
  acceptServiceProviderInvitationUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeServiceProviderCompanyEntity());
    registerFallbackValue(EntityFactory.makeServiceProviderProfileEntity());
    registerFallbackValue(EntityFactory.makeServiceProviderInvitationEntity());
  });

  setUp(() {
    mockServiceProviderRepository = MockServiceProviderRepository();

    createServiceProviderCompanyUseCase = CreateServiceProviderCompanyUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
    updateServiceProviderCompanyUseCase = UpdateServiceProviderCompanyUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
    createServiceProviderProfileUseCase = CreateServiceProviderProfileUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
    updateServiceProviderProfileUseCase = UpdateServiceProviderProfileUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
    getServiceProviderInvitationsUseCase = GetServiceProviderInvitationsUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
    sendServiceProviderInvitationUseCase = SendServiceProviderInvitationUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
    deleteServiceProviderInvitationUseCase =
        DeleteServiceProviderInvitationUseCase(
          serviceProviderRepository: mockServiceProviderRepository,
        );
    acceptServiceProviderInvitationUseCase =
        AcceptServiceProviderInvitationUseCase(
          repository: mockServiceProviderRepository,
        );
  });

  group('CreateServiceProviderCompanyUseCase', () {
    final tCompany = EntityFactory.makeServiceProviderCompanyEntity();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.createServiceProviderCompany(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await createServiceProviderCompanyUseCase(tCompany);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.createServiceProviderCompany(
          tCompany,
        ),
      ).called(1);
    });
  });

  group('UpdateServiceProviderCompanyUseCase', () {
    final tCompany = EntityFactory.makeServiceProviderCompanyEntity();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.updateServiceProviderCompany(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await updateServiceProviderCompanyUseCase(tCompany);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.updateServiceProviderCompany(
          tCompany,
        ),
      ).called(1);
    });
  });

  group('CreateServiceProviderProfileUseCase', () {
    final tProfile = EntityFactory.makeServiceProviderProfileEntity();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.createServiceProviderProfile(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await createServiceProviderProfileUseCase(tProfile);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.createServiceProviderProfile(
          tProfile,
        ),
      ).called(1);
    });
  });

  group('UpdateServiceProviderProfileUseCase', () {
    final tProfile = EntityFactory.makeServiceProviderProfileEntity();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.updateServiceProviderProfile(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await updateServiceProviderProfileUseCase(tProfile);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.updateServiceProviderProfile(
          tProfile,
        ),
      ).called(1);
    });
  });

  group('GetServiceProviderInvitationsUseCase', () {
    final tCompanyId = faker.guid.guid();
    final tList = EntityFactory.makeServiceProviderInvitationEntityList();

    test('should return list of invitations on success', () async {
      when(
        () =>
            mockServiceProviderRepository.getServiceProviderInvitations(any()),
      ).thenAnswer((_) async => SuccessState(data: tList));

      final result = await getServiceProviderInvitationsUseCase(tCompanyId);

      expect(
        result,
        isA<SuccessState<List<ServiceProviderInvitationEntity>>>(),
      );
      expect((result as SuccessState).data, tList);
      verify(
        () => mockServiceProviderRepository.getServiceProviderInvitations(
          tCompanyId,
        ),
      ).called(1);
    });
  });

  group('SendServiceProviderInvitationUseCase', () {
    final tParams = SendServiceProviderInvitationParams(
      serviceProviderCompanyId: faker.guid.guid(),
      email: faker.internet.email(),
    );

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.sendServiceProviderInvitation(
          serviceProviderCompanyId: any(named: 'serviceProviderCompanyId'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await sendServiceProviderInvitationUseCase(tParams);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.sendServiceProviderInvitation(
          serviceProviderCompanyId: tParams.serviceProviderCompanyId,
          email: tParams.email,
        ),
      ).called(1);
    });
  });

  group('DeleteServiceProviderInvitationUseCase', () {
    final tInvitationId = faker.guid.guid();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.deleteServiceProviderInvitation(
          any(),
        ),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await deleteServiceProviderInvitationUseCase(
        tInvitationId,
      );

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.deleteServiceProviderInvitation(
          tInvitationId,
        ),
      ).called(1);
    });
  });

  group('GetServiceProviderProfilesByCompanyIdsUseCase', () {
    final tCompanyIds = [faker.guid.guid(), faker.guid.guid()];
    final tProfiles = [EntityFactory.makeServiceProviderProfileEntity()];
    late GetServiceProviderProfilesByCompanyIdsUseCase useCase;

    setUp(() {
      useCase = GetServiceProviderProfilesByCompanyIdsUseCase(
        serviceProviderRepository: mockServiceProviderRepository,
      );
    });

    test('should return list of profiles on success', () async {
      when(
        () => mockServiceProviderRepository
            .getServiceProviderProfilesByCompanyIds(any()),
      ).thenAnswer((_) async => SuccessState(data: tProfiles));

      final result = await useCase(tCompanyIds);

      expect(result, isA<SuccessState<List<ServiceProviderProfileEntity>>>());
      expect((result as SuccessState).data, tProfiles);
      verify(
        () => mockServiceProviderRepository
            .getServiceProviderProfilesByCompanyIds(tCompanyIds),
      ).called(1);
    });
  });

  group('AcceptServiceProviderInvitationUseCase', () {
    final tEmail = faker.internet.email();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.acceptServiceProviderInvitation(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await acceptServiceProviderInvitationUseCase(tEmail);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.acceptServiceProviderInvitation(
          tEmail,
        ),
      ).called(1);
    });
  });
}
