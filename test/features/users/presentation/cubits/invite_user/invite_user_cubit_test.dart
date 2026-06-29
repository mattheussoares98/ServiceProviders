import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/users/domain/entities/invite_user_params.dart';
import 'package:clean_architecture/features/users/domain/use_cases/invite_user_use_case.dart';
import 'package:clean_architecture/features/users/presentation/cubits/invite_user/invite_user_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/invite_user/invite_user_usecases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

class MockInviteUserUseCase extends Mock implements InviteUserUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InviteUserCubit cubit;
  late MockInviteUserUseCase mockInviteUserUseCase;
  late MockGetSessionUserUseCase mockGetSessionUserUseCase;
  late MockNavigationClient mockNavigationClient;
  late String email;
  late String groupId;

  setUpAll(() {
    registerFallbackValue(
      const InviteUserParams(email: '', companyId: '', groupId: ''),
    );
  });

  setUp(() {
    mockInviteUserUseCase = MockInviteUserUseCase();
    mockGetSessionUserUseCase = MockGetSessionUserUseCase();
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    email = faker.internet.email();
    groupId = faker.guid.guid();

    final useCases = InviteUserCubitUseCases(
      getSessionUser: mockGetSessionUserUseCase,
      inviteUser: mockInviteUserUseCase,
    );
    cubit = InviteUserCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);
  group('InviteUserCubit', () {
    test('initial state should be InviteUserState', () {
      expect(cubit.state, const InviteUserState());
    });

    blocTest<InviteUserCubit, InviteUserState>(
      'emits [loading, loaded] on successful invitation',
      build: () {
        when(() => mockGetSessionUserUseCase()).thenReturn(
          EntityFactory.makeUserProfileEntity().copyWith(
            companyId: 'company-id-123',
          ),
        );
        when(
          () => mockInviteUserUseCase(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        return cubit;
      },
      act: (c) async => expect(
        await c.invite(email: email, groupId: groupId),
        isTrue,
      ),
      verify: (cubit) => verify(
        () => mockInviteUserUseCase(
          InviteUserParams(
            email: email,
            companyId: 'company-id-123',
            groupId: groupId,
          ),
        ),
      ).called(1),
      expect: () => [
        isA<InviteUserState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<InviteUserState>().having(
          (s) => s.status,
          'status',
          StateStatus.loaded,
        ),
      ],
    );

    blocTest<InviteUserCubit, InviteUserState>(
      'emits [loading, loaded] with errorMessage on failed invitation',
      build: () {
        when(() => mockGetSessionUserUseCase()).thenReturn(
          EntityFactory.makeUserProfileEntity().copyWith(
            companyId: 'company-id-123',
          ),
        );
        when(() => mockInviteUserUseCase(any())).thenAnswer(
          (_) async => FailureState(message: 'Error sending invite'),
        );
        return cubit;
      },
      act: (c) async => expect(
        await c.invite(email: email, groupId: groupId),
        isFalse,
      ),
      verify: (cubit) => verify(
        () => mockInviteUserUseCase(
          InviteUserParams(
            email: email,
            companyId: 'company-id-123',
            groupId: groupId,
          ),
        ),
      ).called(1),
      expect: () => [
        isA<InviteUserState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<InviteUserState>().having(
          (s) => s.status,
          'status',
          StateStatus.loaded,
        ),
      ],
    );

    blocTest<InviteUserCubit, InviteUserState>(
      'emits [error] and returns false when companyId is empty',
      build: () {
        when(() => mockGetSessionUserUseCase()).thenReturn(
          EntityFactory.makeUserProfileEntity().copyWith(annulCompanyId: true),
        );
        return cubit;
      },
      act: (c) async => expect(
        await c.invite(email: email, groupId: groupId),
        isFalse,
      ),
      verify: (cubit) => verifyNever(() => mockInviteUserUseCase(any())),
      expect: () => [
        isA<InviteUserState>().having(
          (s) => s.status,
          'status',
          StateStatus.error,
        ),
      ],
    );
  });
}
