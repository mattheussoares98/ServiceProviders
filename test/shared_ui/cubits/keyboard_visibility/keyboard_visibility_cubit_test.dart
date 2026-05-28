import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/keyboard_visibility/keyboard_visibility_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../testing/mocks/client_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeyboardVisibilityCubit', () {
    late KeyboardVisibilityCubit keyboardVisibilityCubit;
    late MockNavigationClient mockNavigationClient;

    setUp(() {
      mockNavigationClient = MockNavigationClient();
      GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);
      keyboardVisibilityCubit = KeyboardVisibilityCubit();
    });

    tearDown(() {
      keyboardVisibilityCubit.close();
      GetIt.I.unregister<NavigationClient>();
    });

    test('initial state should be false in test environment', () {
      expect(keyboardVisibilityCubit.state, isFalse);
    });

    blocTest<KeyboardVisibilityCubit, bool>(
      'does not emit change if keyboard status does not change',
      build: () => keyboardVisibilityCubit,
      act: (cubit) {
        cubit.update();
      },
      expect: () => <bool>[],
    );
  });
}
