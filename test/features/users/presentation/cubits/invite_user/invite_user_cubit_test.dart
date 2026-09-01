import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/invite_user_params.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/invite_user_use_case.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/invite_user/invite_user_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/invite_user/invite_user_usecases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

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
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
  late String email;
  late String groupId;
  late String companyId;

  setUpAll(() {
    registerFallbackValue(
      const InviteUserParams(email: '', companyId: '', groupId: ''),
    );
  });

  setUp(() {
    mockInviteUserUseCase = MockInviteUserUseCase();
    mockGetSessionUserUseCase = MockGetSessionUserUseCase();
    mockNavigationClient = MockNavigationClient();
    mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    email = faker.internet.email();
    groupId = faker.guid.guid();
    companyId = faker.guid.guid();

    final useCases = InviteUserCubitUseCases(
      getActiveCompanyId: mockGetActiveCompanyIdUseCase,
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
      'emits [running, success] on successful invitation',
      build: () {
        when(() => mockGetSessionUserUseCase()).thenReturn(
          EntityFactory.makeUserProfileEntity().copyWith(companyId: companyId),
        );
        when(
          () => mockInviteUserUseCase(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn(companyId);
        return cubit;
      },
      act: (c) async =>
          expect(await c.invite(email: email, groupId: groupId), isTrue),
      verify: (cubit) => verify(
        () => mockInviteUserUseCase(
          InviteUserParams(
            email: email,
            companyId: companyId,
            groupId: groupId,
          ),
        ),
      ).called(1),
      expect: () => [
        isA<InviteUserState>().having(
          (s) => s.sections[InviteUserSections.invite],
          'sections[invite]',
          SectionStatus.running,
        ),
        isA<InviteUserState>().having(
          (s) => s.sections[InviteUserSections.invite],
          'sections[invite]',
          SectionStatus.success,
        ),
      ],
    );

    blocTest<InviteUserCubit, InviteUserState>(
      'emits [running, error] with errorMessage on failed invitation',
      build: () {
        when(() => mockGetSessionUserUseCase()).thenReturn(
          EntityFactory.makeUserProfileEntity().copyWith(companyId: companyId),
        );
        when(() => mockInviteUserUseCase(any())).thenAnswer(
          (_) async => FailureState(message: 'Error sending invite'),
        );
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn(companyId);

        return cubit;
      },
      act: (c) async =>
          expect(await c.invite(email: email, groupId: groupId), isFalse),
      verify: (cubit) => verify(
        () => mockInviteUserUseCase(
          InviteUserParams(
            email: email,
            companyId: companyId,
            groupId: groupId,
          ),
        ),
      ).called(1),
      expect: () => [
        isA<InviteUserState>().having(
          (s) => s.sections[InviteUserSections.invite],
          'sections[invite]',
          SectionStatus.running,
        ),
        isA<InviteUserState>()
            .having(
              (s) => s.sections[InviteUserSections.invite],
              'sections[invite]',
              SectionStatus.error,
            )
            .having((s) => s.errorMessage, 'errorMessage', 'Error sending invite'),
      ],
    );

    blocTest<InviteUserCubit, InviteUserState>(
      'emits [running, error] and returns false when companyId is empty',
      build: () {
        when(() => mockGetSessionUserUseCase()).thenReturn(
          EntityFactory.makeUserProfileEntity().copyWith(annulCompanyId: true),
        );
        when(
          () => mockInviteUserUseCase(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn('');

        return cubit;
      },
      act: (c) async =>
          expect(await c.invite(email: email, groupId: groupId), isFalse),
      verify: (cubit) => verify(() => mockInviteUserUseCase(any())).called(1),
      expect: () => [
        isA<InviteUserState>().having(
          (s) => s.sections[InviteUserSections.invite],
          'sections[invite]',
          SectionStatus.running,
        ),
        isA<InviteUserState>()
            .having(
              (s) => s.sections[InviteUserSections.invite],
              'sections[invite]',
              SectionStatus.error,
            )
            .having((s) => s.errorMessage, 'errorMessage', 'Error'),
      ],
    );
  });
}
