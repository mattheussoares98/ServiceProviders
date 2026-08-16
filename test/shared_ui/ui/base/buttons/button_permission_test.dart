import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

import '../../../../../testing/mocks/entity_factory.dart';

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class ButtonTestCase {
  const ButtonTestCase({
    required this.name,
    required this.builder,
    required this.finder,
  });
  final String name;
  final Widget Function(ActionPermission? permission) builder;
  final Finder finder;
}

void main() {
  late MockUsersCubit mockUsersCubit;
  late MockSessionCubit mockSessionCubit;
  setUp(() {
    mockUsersCubit = MockUsersCubit();
    mockSessionCubit = MockSessionCubit();
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
    when(() => mockUsersCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUsersCubit.hasActionPermission(any())).thenReturn(true);
    when(() => mockSessionCubit.state).thenReturn(
      SessionState.initial().copyWith(
        user: EntityFactory.makeUserProfileEntity(),
      ),
    );
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  setUpAll(() {
    registerFallbackValue(
      const ActionPermission.resource(
        resourceType: ResourceType.users,
        permissionAction: PermissionAction.create,
      ),
    );
  });

  Widget buildTestWidget(Widget button) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UsersCubit>.value(value: mockUsersCubit),
        BlocProvider<SessionCubit>.value(value: mockSessionCubit),
      ],
      child: MaterialApp(home: Scaffold(body: button)),
    );
  }

  final buttonCases = [
    ButtonTestCase(
      name: 'PrimaryButton',
      builder: (permission) =>
          BaseButton(onTap: () {}, text: 'Test Button', permission: permission),
      finder: find.text('Test Button'),
    ),
    ButtonTestCase(
      name: 'SecondaryButton',
      builder: (permission) => SecondaryButton(
        onTap: () {},
        text: 'Test Button',
        permission: permission,
      ),
      finder: find.text('Test Button'),
    ),
    ButtonTestCase(
      name: 'BaseTextButton',
      builder: (permission) => BaseTextButton(
        onPressed: () {},
        text: 'Test Button',
        permission: permission,
      ),
      finder: find.text('Test Button'),
    ),
    ButtonTestCase(
      name: 'BaseIconButton',
      builder: (permission) => BaseIconButton(
        onPressed: () {},
        platformIcon: const PlatformIcon(
          materialIcon: Icons.star,
          cupertinoIcon: CupertinoIcons.star,
        ),
        permission: permission,
      ),
      finder: find.byIcon(
        PlatformUtil.isCupertino ? CupertinoIcons.star : Icons.star,
      ),
    ),
  ];

  group('Button Permission Widget Tests', () {
    for (final testCase in buttonCases) {
      group(testCase.name, () {
        testWidgets('renders normally when permission is null', (tester) async {
          await tester.pumpWidget(buildTestWidget(testCase.builder(null)));
          expect(testCase.finder, findsOneWidget);
        });

        testWidgets('renders normally when permission is granted', (
          tester,
        ) async {
          const permission = ActionPermission.resource(
            resourceType: ResourceType.users,
            permissionAction: PermissionAction.create,
          );

          when(
            () => mockUsersCubit.hasActionPermission(permission),
          ).thenReturn(true);

          await tester.pumpWidget(
            buildTestWidget(testCase.builder(permission)),
          );

          expect(testCase.finder, findsOneWidget);
          verify(
            () => mockUsersCubit.hasActionPermission(permission),
          ).called(1);
        });

        testWidgets('renders SizedBox.shrink() when permission is denied', (
          tester,
        ) async {
          const permission = ActionPermission.resource(
            resourceType: ResourceType.users,
            permissionAction: PermissionAction.create,
          );

          when(
            () => mockUsersCubit.hasActionPermission(permission),
          ).thenReturn(false);

          await tester.pumpWidget(
            buildTestWidget(testCase.builder(permission)),
          );

          expect(testCase.finder, findsNothing);
          verify(
            () => mockUsersCubit.hasActionPermission(permission),
          ).called(1);
        });
      });
    }
  });
}
