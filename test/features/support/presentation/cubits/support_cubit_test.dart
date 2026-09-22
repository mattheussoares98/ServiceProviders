import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service.dart';
import 'package:o_jogo_da_obra/features/support/presentation/cubits/support/support_cubit.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/services.dart';

void main() {
  late MockSupportService mockSupportService;
  late MockNavigationClient mockNavigationClient;

  setUp(() {
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    mockSupportService = MockSupportService();
    when(
      () => mockSupportService.supportEmail,
    ).thenReturn('contact@soarescodes.com.br');
    when(() => mockSupportService.isEmailConfigured).thenReturn(true);
  });

  tearDown(GetIt.I.reset);

  SupportCubit buildCubit() {
    return SupportCubit(supportService: mockSupportService);
  }

  group('SupportCubit - initialization', () {
    test('initial state is correct', () {
      final cubit = buildCubit();
      expect(cubit.state, const SupportState.initial());
      expect(cubit.state.supportEmail, isEmpty);
      expect(cubit.state.isEmailAvailable, isFalse);
    });

    test('init sets support email and availability', () {
      final cubit = buildCubit()..init();
      expect(cubit.state.supportEmail, 'contact@soarescodes.com.br');
      expect(cubit.state.isEmailAvailable, isTrue);
    });
  });

  group('SupportCubit - updateDescription', () {
    blocTest<SupportCubit, SupportState>(
      'updates description text in state',
      build: buildCubit,
      act: (cubit) => cubit.updateDescription('Need help'),
      expect: () => [
        isA<SupportState>()
            .having((s) => s.userDescription, 'userDescription', 'Need help')
            .having((s) => s.hasValidDraft, 'hasValidDraft', isTrue),
      ],
    );
  });

  group('SupportCubit - launchEmail', () {
    blocTest<SupportCubit, SupportState>(
      'emits running then success when service launch succeeds',
      build: () {
        when(
          () => mockSupportService.launchSupportEmail(
            userDescription: any(named: 'userDescription'),
            platformName: any(named: 'platformName'),
          ),
        ).thenAnswer((_) async => const LauncherResult.success());
        return buildCubit()
          ..init()
          ..updateDescription('Need assistance');
      },
      act: (cubit) => cubit.launchEmail(),
      expect: () => [
        isA<SupportState>().having(
          (s) => s.section(SupportSection.launch).status,
          'status',
          SectionStatus.running,
        ),
        isA<SupportState>().having(
          (s) => s.section(SupportSection.launch).status,
          'status',
          SectionStatus.success,
        ),
      ],
    );

    blocTest<SupportCubit, SupportState>(
      'emits error when email is not configured',
      build: () {
        when(() => mockSupportService.isEmailConfigured).thenReturn(false);
        return buildCubit()
          ..init()
          ..updateDescription('Need assistance');
      },
      act: (cubit) => cubit.launchEmail(),
      expect: () => [
        isA<SupportState>()
            .having(
              (s) => s.section(SupportSection.launch).status,
              'status',
              SectionStatus.error,
            )
            .having(
              (s) => s.section(SupportSection.launch).errorMessage,
              'errorMessage',
              'unconfigured_email',
            ),
      ],
    );

    blocTest<SupportCubit, SupportState>(
      'emits error when description is invalid or empty',
      build: () => buildCubit()..init(),
      act: (cubit) => cubit.launchEmail(),
      expect: () => [
        isA<SupportState>()
            .having(
              (s) => s.section(SupportSection.launch).status,
              'status',
              SectionStatus.error,
            )
            .having(
              (s) => s.section(SupportSection.launch).errorMessage,
              'errorMessage',
              'invalid_description',
            ),
      ],
    );

    blocTest<SupportCubit, SupportState>(
      'emits error and retains user draft when launch fails',
      build: () {
        when(
          () => mockSupportService.launchSupportEmail(
            userDescription: any(named: 'userDescription'),
            platformName: any(named: 'platformName'),
          ),
        ).thenAnswer(
          (_) async => const LauncherResult.failure('cannot_launch'),
        );
        return buildCubit()
          ..init()
          ..updateDescription('Valid issue description');
      },
      act: (cubit) => cubit.launchEmail(),
      expect: () => [
        isA<SupportState>().having(
          (s) => s.section(SupportSection.launch).status,
          'status',
          SectionStatus.running,
        ),
        isA<SupportState>()
            .having(
              (s) => s.section(SupportSection.launch).status,
              'status',
              SectionStatus.error,
            )
            .having(
              (s) => s.section(SupportSection.launch).errorMessage,
              'errorMessage',
              'cannot_launch',
            )
            .having(
              (s) => s.userDescription,
              'userDescription',
              'Valid issue description',
            ),
      ],
    );
  });

  group('SupportCubit - copyText', () {
    blocTest<SupportCubit, SupportState>(
      'emits running then success and updates lastCopiedText when copy succeeds',
      build: () {
        when(
          () => mockSupportService.copyToClipboard(any()),
        ).thenAnswer((_) async => const LauncherResult.success());
        return buildCubit();
      },
      act: (cubit) => cubit.copyText('contact@soarescodes.com.br'),
      expect: () => [
        isA<SupportState>().having(
          (s) => s.section(SupportSection.copy).status,
          'status',
          SectionStatus.running,
        ),
        isA<SupportState>()
            .having(
              (s) => s.section(SupportSection.copy).status,
              'status',
              SectionStatus.success,
            )
            .having(
              (s) => s.lastCopiedText,
              'lastCopiedText',
              'contact@soarescodes.com.br',
            ),
      ],
    );

    blocTest<SupportCubit, SupportState>(
      'emits running then error when copy fails',
      build: () {
        when(
          () => mockSupportService.copyToClipboard(any()),
        ).thenAnswer((_) async => const LauncherResult.failure('copy_failed'));
        return buildCubit();
      },
      act: (cubit) => cubit.copyText('contact@soarescodes.com.br'),
      expect: () => [
        isA<SupportState>().having(
          (s) => s.section(SupportSection.copy).status,
          'status',
          SectionStatus.running,
        ),
        isA<SupportState>()
            .having(
              (s) => s.section(SupportSection.copy).status,
              'status',
              SectionStatus.error,
            )
            .having(
              (s) => s.section(SupportSection.copy).errorMessage,
              'errorMessage',
              'copy_failed',
            ),
      ],
    );
  });
}
