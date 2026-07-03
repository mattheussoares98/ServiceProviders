import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUsersCubit extends MockCubit<UsersState> implements UsersCubit {}

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

  setUp(() {
    mockUsersCubit = MockUsersCubit();
    when(() => mockUsersCubit.state).thenReturn(const UsersState.initial());
  });

  Widget buildTestWidget(Widget button) {
    return BlocProvider<UsersCubit>.value(
      value: mockUsersCubit,
      child: MaterialApp(home: Scaffold(body: button)),
    );
  }

  final buttonCases = [
    ButtonTestCase(
      name: 'PrimaryButton',
      builder: (permission) => PrimaryButton(
        onTap: () {},
        text: 'Test Button',
        permission: permission,
      ),
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
          const permission = ActionPermission(
            resource: ResourceType.users,
            action: PermissionAction.create,
          );

          when(
            () => mockUsersCubit.hasPermission(
              ResourceType.users,
              PermissionAction.create,
            ),
          ).thenReturn(true);

          await tester.pumpWidget(
            buildTestWidget(testCase.builder(permission)),
          );

          expect(testCase.finder, findsOneWidget);
          verify(
            () => mockUsersCubit.hasPermission(
              ResourceType.users,
              PermissionAction.create,
            ),
          ).called(1);
        });

        testWidgets('renders SizedBox.shrink() when permission is denied', (
          tester,
        ) async {
          const permission = ActionPermission(
            resource: ResourceType.users,
            action: PermissionAction.create,
          );

          when(
            () => mockUsersCubit.hasPermission(
              ResourceType.users,
              PermissionAction.create,
            ),
          ).thenReturn(false);

          await tester.pumpWidget(
            buildTestWidget(testCase.builder(permission)),
          );

          expect(testCase.finder, findsNothing);
          verify(
            () => mockUsersCubit.hasPermission(
              ResourceType.users,
              PermissionAction.create,
            ),
          ).called(1);
        });
      });
    }
  });
}
