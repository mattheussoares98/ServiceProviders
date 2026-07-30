import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_selected_mode_use_case.dart';

class MockLocalStorageClient extends Mock implements LocalStorageClient {}

void main() {
  late MockLocalStorageClient mockLocalStorageClient;
  late SaveSelectedModeUseCase saveSelectedModeUseCase;
  late GetSelectedModeUseCase getSelectedModeUseCase;

  setUp(() {
    mockLocalStorageClient = MockLocalStorageClient();
    saveSelectedModeUseCase = SaveSelectedModeUseCase(mockLocalStorageClient);
    getSelectedModeUseCase = GetSelectedModeUseCase(mockLocalStorageClient);
  });

  group('SelectedModeUseCases', () {
    group('SaveSelectedModeUseCase', () {
      test('should call localStorageClient.saveSelectedMode with mode', () async {
        when(
          () => mockLocalStorageClient.saveSelectedMode(any()),
        ).thenAnswer((_) async {});

        await saveSelectedModeUseCase.call(AppMode.provider.name);

        verify(
          () => mockLocalStorageClient.saveSelectedMode(AppMode.provider.name),
        ).called(1);
      });
    });

    group('GetSelectedModeUseCase', () {
      test('should return selected mode from localStorageClient', () {
        when(
          () => mockLocalStorageClient.getSelectedMode(),
        ).thenReturn(AppMode.provider.name);

        final result = getSelectedModeUseCase.call();

        expect(result, AppMode.provider.name);
        verify(() => mockLocalStorageClient.getSelectedMode()).called(1);
      });
    });
  });
}
