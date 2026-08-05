import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/clear_local_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_avatar_use_case.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';
import '../../../../attachments/presentation/cubits/attachments/attachments_cubit_test.dart'
    hide MockGetSessionUserUseCase;

class MockClearLocalAttachmentsUseCase extends Mock
    implements ClearLocalAttachmentsUseCase {}

class MockUpdateUserAvatarUseCase extends Mock
    implements UpdateUserAvatarUseCase {}

void main() {
  late MockLogOutUseCase mockLogOutUseCase;
  late MockClearLocalAttachmentsUseCase mockClearLocalAttachmentsUseCase;
  late MockNavigationClient mockNavigationClient;
  late HomeCubit homeCubit;
  late MockGetSessionUserUseCase mockGetSessionUserUseCase;
  late MockPickAttachmentUseCase mockpickAttachment;
  late MockUpdateUserAvatarUseCase mockUpdateUserAvatarUseCase;

  setUpAll(() {
    registerFallbackValue(const LoginRoute());
    registerFallbackValue(const ChecklistsRoute());
    registerFallbackValue(const MaintenancePlansRoute());
    registerFallbackValue(
      CreateUpdateServiceProviderCompanyRoute(serviceProviderCompanyId: '0'),
    );
    registerFallbackValue(
      const PickAttachmentParams(
        source: AttachmentSource.gallery,
        workOrderId: '',
        companyId: '',
        userId: '',
      ),
    );
    registerFallbackValue(
      UpdateUserAvatarParams(
        userProfile: UserProfileEntity.empty(),
        localPath: '',
      ),
    );
  });

  setUp(() {
    mockLogOutUseCase = MockLogOutUseCase();
    mockClearLocalAttachmentsUseCase = MockClearLocalAttachmentsUseCase();
    mockNavigationClient = MockNavigationClient();
    mockGetSessionUserUseCase = MockGetSessionUserUseCase();
    mockpickAttachment = MockPickAttachmentUseCase();
    mockUpdateUserAvatarUseCase = MockUpdateUserAvatarUseCase();

    // Register NavigationClient in GetIt so base cubit routes resolve correctly
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(
      () => mockClearLocalAttachmentsUseCase(),
    ).thenAnswer((_) async => SuccessState.nil);

    final useCases = HomeCubitUseCases(
      logOut: mockLogOutUseCase,
      clearLocalAttachments: mockClearLocalAttachmentsUseCase,
      getSessionUser: mockGetSessionUserUseCase,
      pickAttachment: mockpickAttachment,
      updateUserAvatar: mockUpdateUserAvatarUseCase,
    );
    homeCubit = HomeCubit(useCases: useCases);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('HomeCubit', () {
    blocTest<HomeCubit, HomeState>(
      'logout should call LogOutUseCase and replace route with SplashRoute',
      build: () {
        when(
          () => mockClearLocalAttachmentsUseCase.call(),
        ).thenAnswer((_) async => SuccessState.nil);
        when(() => mockLogOutUseCase.call()).thenAnswer((_) async {});
        return homeCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => <HomeState>[],
      verify: (cubit) {
        verify(() => mockClearLocalAttachmentsUseCase.call()).called(1);
        verify(() => mockLogOutUseCase.call()).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const SplashRoute()),
        ).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'navigateToCompany should push CompanyRoute',
      build: () => homeCubit,
      act: (cubit) => cubit.navigateToCompany(),
      expect: () => <HomeState>[],
      verify: (cubit) {
        verify(
          () => mockNavigationClient.pushRoute(const CompanyRoute()),
        ).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'navigateToPermissions should push PermissionsRoute',
      build: () => homeCubit,
      act: (cubit) => cubit.navigateToPermissions(),
      expect: () => <HomeState>[],
      verify: (cubit) {
        verify(
          () =>
              mockNavigationClient.pushRoute(const UsersAndPermissionsRoute()),
        ).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'navigateToChecklists should push ChecklistsRoute',
      build: () => homeCubit,
      act: (cubit) => cubit.navigateToChecklists(),
      expect: () => <HomeState>[],
      verify: (cubit) {
        verify(
          () => mockNavigationClient.pushRoute(const ChecklistsRoute()),
        ).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'navigateToMaintenancePlans should push MaintenancePlansRoute',
      build: () => homeCubit,
      act: (cubit) => cubit.navigateToMaintenancePlans(),
      expect: () => <HomeState>[],
      verify: (cubit) {
        verify(
          () => mockNavigationClient.pushRoute(const MaintenancePlansRoute()),
        ).called(1);
      },
    );

    final tUser = EntityFactory.makeUserProfileEntity();
    final tAttachment = EntityFactory.makeAttachmentEntity().copyWith(
      localPath: 'path/to/file.jpg',
    );

    blocTest<HomeCubit, HomeState>(
      'changeAvatar should successfully change avatar',
      build: () {
        when(() => mockGetSessionUserUseCase.call()).thenReturn(tUser);
        when(
          () => mockpickAttachment.call(
            PickAttachmentParams(
              source: AttachmentSource.gallery,
              workOrderId: 'avatar',
              companyId: tUser.companyId,
              userId: tUser.id,
              multiple: false,
            ),
          ),
        ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
        when(
          () => mockUpdateUserAvatarUseCase.call(
            UpdateUserAvatarParams(
              userProfile: tUser,
              localPath: tAttachment.localPath!,
            ),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return homeCubit;
      },
      act: (cubit) => cubit.changeAvatar(AttachmentSource.gallery),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', StateStatus.saving),
        isA<HomeState>().having((s) => s.status, 'status', StateStatus.loaded),
      ],
      verify: (cubit) {
        verify(() => mockGetSessionUserUseCase.call()).called(1);
        verify(
          () => mockpickAttachment.call(
            PickAttachmentParams(
              source: AttachmentSource.gallery,
              workOrderId: 'avatar',
              companyId: tUser.companyId,
              userId: tUser.id,
              multiple: false,
            ),
          ),
        ).called(1);
        verify(
          () => mockUpdateUserAvatarUseCase.call(
            UpdateUserAvatarParams(
              userProfile: tUser,
              localPath: tAttachment.localPath!,
            ),
          ),
        ).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'changeAvatar should do nothing if picking returns empty list',
      build: () {
        when(() => mockGetSessionUserUseCase.call()).thenReturn(tUser);
        when(
          () => mockpickAttachment.call(
            PickAttachmentParams(
              source: AttachmentSource.gallery,
              workOrderId: 'avatar',
              companyId: tUser.companyId,
              userId: tUser.id,
              multiple: false,
            ),
          ),
        ).thenAnswer((_) async => const SuccessState(data: []));
        return homeCubit;
      },
      act: (cubit) => cubit.changeAvatar(AttachmentSource.gallery),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', StateStatus.saving),
        isA<HomeState>().having((s) => s.status, 'status', StateStatus.loaded),
      ],
      verify: (cubit) {
        verify(() => mockGetSessionUserUseCase.call()).called(1);
        verify(
          () => mockpickAttachment.call(
            PickAttachmentParams(
              source: AttachmentSource.gallery,
              workOrderId: 'avatar',
              companyId: tUser.companyId,
              userId: tUser.id,
              multiple: false,
            ),
          ),
        ).called(1);
        verifyNever(() => mockUpdateUserAvatarUseCase.call(any()));
      },
    );

    blocTest<HomeCubit, HomeState>(
      'changeAvatar should emit savingError when upload fails',
      build: () {
        when(() => mockGetSessionUserUseCase.call()).thenReturn(tUser);
        when(
          () => mockpickAttachment.call(
            PickAttachmentParams(
              source: AttachmentSource.gallery,
              workOrderId: 'avatar',
              companyId: tUser.companyId,
              userId: tUser.id,
              multiple: false,
            ),
          ),
        ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
        when(
          () => mockUpdateUserAvatarUseCase.call(
            UpdateUserAvatarParams(
              userProfile: tUser,
              localPath: tAttachment.localPath!,
            ),
          ),
        ).thenAnswer((_) async => FailureState(message: 'Upload error'));
        return homeCubit;
      },
      act: (cubit) => cubit.changeAvatar(AttachmentSource.gallery),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', StateStatus.saving),
        isA<HomeState>().having(
          (s) => s.status,
          'status',
          StateStatus.savingError,
        ),
      ],
      verify: (cubit) {
        verify(() => mockGetSessionUserUseCase.call()).called(1);
        verify(
          () => mockpickAttachment.call(
            PickAttachmentParams(
              source: AttachmentSource.gallery,
              workOrderId: 'avatar',
              companyId: tUser.companyId,
              userId: tUser.id,
              multiple: false,
            ),
          ),
        ).called(1);
        verify(
          () => mockUpdateUserAvatarUseCase.call(
            UpdateUserAvatarParams(
              userProfile: tUser,
              localPath: tAttachment.localPath!,
            ),
          ),
        ).called(1);
      },
    );
  });
}
