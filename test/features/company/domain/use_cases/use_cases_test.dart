import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/plan_type.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/can_provider_create_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/check_attachment_quota_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/check_feature_enabled_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/check_observation_quota_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/check_work_order_quota_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_all_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/save_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/save_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/update_company_logo_use_case.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/maintenance_plan_factory.dart';
import '../../../../../testing/mocks/factories/service_provider_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../testing/mocks/factories/work_order_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../testing/mocks/services.dart';
import '../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  late MockCompanyRepository mockRepository;
  late CreateCompanyUseCase createCompanyUseCase;
  late GetCompanyUseCase getCompanyUseCase;
  late GetAllCompaniesUseCase getAllCompaniesUseCase;
  late SaveCompanyUseCase saveCompanyUseCase;
  late GetCompanyParametersUseCase getCompanyParametersUseCase;
  late SaveCompanyParametersUseCase saveCompanyParametersUseCase;
  late MockStorageClient mockStorageClient;
  late MockFileService mockFileService;
  late UpdateCompanyLogoUseCase updateCompanyLogoUseCase;

  setUpAll(() {
    registerFallbackValue(UserFactory.makeCompanyEntity());
    registerFallbackValue(UserFactory.makeCompanyParameterEntity());
  });

  setUp(() {
    mockRepository = MockCompanyRepository();
    createCompanyUseCase = CreateCompanyUseCase(
      companyRepository: mockRepository,
    );
    getCompanyUseCase = GetCompanyUseCase(companyRepository: mockRepository);
    getAllCompaniesUseCase = GetAllCompaniesUseCase(repository: mockRepository);
    saveCompanyUseCase = SaveCompanyUseCase(companyRepository: mockRepository);
    getCompanyParametersUseCase = GetCompanyParametersUseCase(
      companyRepository: mockRepository,
    );
    saveCompanyParametersUseCase = SaveCompanyParametersUseCase(
      companyRepository: mockRepository,
    );
    mockStorageClient = MockStorageClient();
    mockFileService = MockFileService();
    updateCompanyLogoUseCase = UpdateCompanyLogoUseCase(
      storageClient: mockStorageClient,
      companyRepository: mockRepository,
      fileService: mockFileService,
    );
  });

  final tCompanyEntity = UserFactory.makeCompanyEntity();
  final tParametersEntity = UserFactory.makeCompanyParameterEntity();
  final tCompanyId = tCompanyEntity.id;

  group('Company Use Cases', () {
    group('CreateCompanyUseCase', () {
      test(
        'should call repository.createCompany and return company on success',
        () async {
          when(
            () => mockRepository.createCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyEntity));

          final result = await createCompanyUseCase(tCompanyEntity);

          expect(result, isA<SuccessState<CompanyEntity>>());
          expect(result.data, tCompanyEntity);
          verify(() => mockRepository.createCompany(tCompanyEntity)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(() => mockRepository.createCompany(any())).thenAnswer(
          (_) async => FailureState<CompanyEntity>(message: 'Create failed'),
        );

        final result = await createCompanyUseCase(tCompanyEntity);

        expect(result, isA<FailureState<CompanyEntity>>());
        expect(result.message, 'Create failed');
        verify(() => mockRepository.createCompany(tCompanyEntity)).called(1);
      });
    });

    group('GetCompanyUseCase', () {
      test(
        'should call repository.getCompany and return company on success',
        () async {
          when(
            () => mockRepository.getCompany(
              any(),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer((_) async => SuccessState(data: tCompanyEntity));

          final result = await getCompanyUseCase(tCompanyId);

          expect(result, isA<SuccessState<CompanyEntity>>());
          expect(result.data, tCompanyEntity);
          verify(() => mockRepository.getCompany(tCompanyId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.getCompany(
            any(),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => FailureState<CompanyEntity>(message: 'Fetch failed'),
        );

        final result = await getCompanyUseCase(tCompanyId);

        expect(result, isA<FailureState<CompanyEntity>>());
        expect(result.message, 'Fetch failed');
        verify(() => mockRepository.getCompany(tCompanyId)).called(1);
      });
    });

    group('SaveCompanyUseCase', () {
      test(
        'should call repository.saveCompany and return true on success',
        () async {
          when(
            () => mockRepository.saveCompany(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await saveCompanyUseCase(tCompanyEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.saveCompany(tCompanyEntity)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.saveCompany(any()),
        ).thenAnswer((_) async => FailureState<bool>(message: 'Save failed'));

        final result = await saveCompanyUseCase(tCompanyEntity);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Save failed');
        verify(() => mockRepository.saveCompany(tCompanyEntity)).called(1);
      });
    });

    group('GetCompanyParametersUseCase', () {
      test(
        'should call repository.getCompanyParameters and return parameters on success',
        () async {
          when(
            () => mockRepository.getCompanyParameters(any()),
          ).thenAnswer((_) async => SuccessState(data: tParametersEntity));

          final result = await getCompanyParametersUseCase(tCompanyId);

          expect(result, isA<SuccessState<CompanyParameterEntity>>());
          expect(result.data, tParametersEntity);
          verify(
            () => mockRepository.getCompanyParameters(tCompanyId),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(() => mockRepository.getCompanyParameters(any())).thenAnswer(
          (_) async => FailureState<CompanyParameterEntity>(
            message: 'Fetch parameters failed',
          ),
        );

        final result = await getCompanyParametersUseCase(tCompanyId);

        expect(result, isA<FailureState<CompanyParameterEntity>>());
        expect(result.message, 'Fetch parameters failed');
        verify(() => mockRepository.getCompanyParameters(tCompanyId)).called(1);
      });
    });

    group('SaveCompanyParametersUseCase', () {
      test(
        'should call repository.saveCompanyParameters and return true on success',
        () async {
          when(
            () => mockRepository.saveCompanyParameters(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await saveCompanyParametersUseCase(tParametersEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRepository.saveCompanyParameters(tParametersEntity),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(() => mockRepository.saveCompanyParameters(any())).thenAnswer(
          (_) async => FailureState<bool>(message: 'Save parameters failed'),
        );

        final result = await saveCompanyParametersUseCase(tParametersEntity);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Save parameters failed');
        verify(
          () => mockRepository.saveCompanyParameters(tParametersEntity),
        ).called(1);
      });
    });

    group('UpdateCompanyLogoUseCase', () {
      const tLocalPath = '/path/to/logo.png';
      const tPresigned = PresignedUrlResponse(
        uploadUrl: 'https://upload.url',
        fileKey: 'attachments/company/logos/company.png',
        publicUrl: 'https://public.url/logo.png',
      );

      test(
        'should upload logo and save company with updated logoUrl',
        () async {
          when(
            () => mockFileService.getMimeType(any()),
          ).thenReturn('image/png');
          when(
            () => mockStorageClient.getPresignedUploadUrl(any()),
          ).thenAnswer((_) async => const SuccessState(data: tPresigned));
          when(
            () => mockStorageClient.uploadFile(
              presignedUrl: any(named: 'presignedUrl'),
              filePath: any(named: 'filePath'),
              mimeType: any(named: 'mimeType'),
            ),
          ).thenAnswer(
            (_) async =>
                const SuccessState(data: 'https://public.url/logo.png'),
          );
          when(
            () => mockRepository.saveCompany(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await updateCompanyLogoUseCase(
            UpdateCompanyLogoParams(
              company: tCompanyEntity,
              localPath: tLocalPath,
            ),
          );

          expect(result, isA<SuccessState<CompanyEntity>>());
          expect(result.data?.logoUrl, 'https://public.url/logo.png');
          verify(
            () => mockStorageClient.getPresignedUploadUrl(
              'attachments/${tCompanyEntity.id}/logos/${tCompanyEntity.id}.png',
            ),
          ).called(1);
          verify(
            () => mockStorageClient.uploadFile(
              presignedUrl: 'https://upload.url',
              filePath: tLocalPath,
              mimeType: 'image/png',
            ),
          ).called(1);
          verify(
            () => mockRepository.saveCompany(
              tCompanyEntity.copyWith(logoUrl: 'https://public.url/logo.png'),
            ),
          ).called(1);
        },
      );

      test(
        'should return FailureState when getPresignedUploadUrl fails',
        () async {
          when(
            () => mockFileService.getMimeType(any()),
          ).thenReturn('image/png');
          when(
            () => mockStorageClient.getPresignedUploadUrl(any()),
          ).thenAnswer((_) async => FailureState(message: 'Presigned failed'));

          final result = await updateCompanyLogoUseCase(
            UpdateCompanyLogoParams(
              company: tCompanyEntity,
              localPath: tLocalPath,
            ),
          );

          expect(result, isA<FailureState<CompanyEntity>>());
          expect(result.message, 'Presigned failed');
          verifyNever(
            () => mockStorageClient.uploadFile(
              presignedUrl: any(named: 'presignedUrl'),
              filePath: any(named: 'filePath'),
              mimeType: any(named: 'mimeType'),
            ),
          );
        },
      );

      test('should return FailureState when uploadFile fails', () async {
        when(() => mockFileService.getMimeType(any())).thenReturn('image/png');
        when(
          () => mockStorageClient.getPresignedUploadUrl(any()),
        ).thenAnswer((_) async => const SuccessState(data: tPresigned));
        when(
          () => mockStorageClient.uploadFile(
            presignedUrl: any(named: 'presignedUrl'),
            filePath: any(named: 'filePath'),
            mimeType: any(named: 'mimeType'),
          ),
        ).thenAnswer((_) async => FailureState(message: 'Upload failed'));

        final result = await updateCompanyLogoUseCase(
          UpdateCompanyLogoParams(
            company: tCompanyEntity,
            localPath: tLocalPath,
          ),
        );

        expect(result, isA<FailureState<CompanyEntity>>());
        expect(result.message, 'Upload failed');
        verifyNever(() => mockRepository.saveCompany(any()));
      });

      test('should return FailureState when saveCompany fails', () async {
        when(() => mockFileService.getMimeType(any())).thenReturn('image/png');
        when(
          () => mockStorageClient.getPresignedUploadUrl(any()),
        ).thenAnswer((_) async => const SuccessState(data: tPresigned));
        when(
          () => mockStorageClient.uploadFile(
            presignedUrl: any(named: 'presignedUrl'),
            filePath: any(named: 'filePath'),
            mimeType: any(named: 'mimeType'),
          ),
        ).thenAnswer(
          (_) async => const SuccessState(data: 'https://public.url/logo.png'),
        );
        when(
          () => mockRepository.saveCompany(any()),
        ).thenAnswer((_) async => FailureState(message: 'Save failed'));

        final result = await updateCompanyLogoUseCase(
          UpdateCompanyLogoParams(
            company: tCompanyEntity,
            localPath: tLocalPath,
          ),
        );

        expect(result, isA<FailureState<CompanyEntity>>());
        expect(result.message, 'Save failed');
      });
    });

    group('GetAllCompaniesUseCase', () {
      test(
        'should call repository.getAllCompanies and return list on success',
        () async {
          when(
            () => mockRepository.getAllCompanies(),
          ).thenAnswer((_) async => SuccessState(data: [tCompanyEntity]));

          final result = await getAllCompaniesUseCase();

          expect(result, isA<SuccessState<List<CompanyEntity>>>());
          expect(result.data?.first, tCompanyEntity);
          verify(() => mockRepository.getAllCompanies()).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.getAllCompanies(),
        ).thenAnswer((_) async => FailureState(message: 'Get all failed'));

        final result = await getAllCompaniesUseCase();

        expect(result, isA<FailureState<List<CompanyEntity>>>());
      });
    });

    group('CanProviderCreateWorkOrderUseCase', () {
      late CanProviderCreateWorkOrderUseCase canProviderCreateWorkOrderUseCase;
      final tCompany1 =
          ServiceProviderFactory.makeServiceProviderCompanyEntity();
      final tCompany2 =
          ServiceProviderFactory.makeServiceProviderCompanyEntity();

      setUp(() {
        canProviderCreateWorkOrderUseCase = CanProviderCreateWorkOrderUseCase(
          companyRepository: mockRepository,
        );
      });

      test('returns false when companies list is empty', () async {
        final result = await canProviderCreateWorkOrderUseCase(
          const CanProviderCreateWorkOrderParams(companies: []),
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
        verifyZeroInteractions(mockRepository);
      });

      test(
        'returns true when selected company allows work order creation',
        () async {
          when(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).thenAnswer(
            (_) async => SuccessState(
              data: UserFactory.makeCompanyParameterEntity().copyWith(
                allowProviderCreateWorkOrder: true,
              ),
            ),
          );

          final result = await canProviderCreateWorkOrderUseCase(
            CanProviderCreateWorkOrderParams(
              companies: [tCompany1, tCompany2],
              selectedCompanyId: tCompany1.id,
            ),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).called(1);
        },
      );

      test(
        'returns false when selected company forbids work order creation',
        () async {
          when(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).thenAnswer(
            (_) async => SuccessState(
              data: UserFactory.makeCompanyParameterEntity().copyWith(
                allowProviderCreateWorkOrder: false,
              ),
            ),
          );

          final result = await canProviderCreateWorkOrderUseCase(
            CanProviderCreateWorkOrderParams(
              companies: [tCompany1, tCompany2],
              selectedCompanyId: tCompany1.id,
            ),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isFalse);
          verify(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).called(1);
        },
      );

      test(
        'returns false when selectedCompanyId is not found in companies list',
        () async {
          final result = await canProviderCreateWorkOrderUseCase(
            CanProviderCreateWorkOrderParams(
              companies: [tCompany1],
              selectedCompanyId: 'unknown-id',
            ),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isFalse);
          verifyZeroInteractions(mockRepository);
        },
      );

      test(
        'returns true when single company allows work order creation',
        () async {
          when(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).thenAnswer(
            (_) async => SuccessState(
              data: UserFactory.makeCompanyParameterEntity().copyWith(
                allowProviderCreateWorkOrder: true,
              ),
            ),
          );

          final result = await canProviderCreateWorkOrderUseCase(
            CanProviderCreateWorkOrderParams(companies: [tCompany1]),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).called(1);
        },
      );

      test(
        'returns false when single company forbids work order creation',
        () async {
          when(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).thenAnswer(
            (_) async => SuccessState(
              data: UserFactory.makeCompanyParameterEntity().copyWith(
                allowProviderCreateWorkOrder: false,
              ),
            ),
          );

          final result = await canProviderCreateWorkOrderUseCase(
            CanProviderCreateWorkOrderParams(companies: [tCompany1]),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isFalse);
          verify(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).called(1);
        },
      );

      test(
        'returns true when multiple companies and at least one allows it',
        () async {
          when(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).thenAnswer(
            (_) async => SuccessState(
              data: UserFactory.makeCompanyParameterEntity().copyWith(
                allowProviderCreateWorkOrder: false,
              ),
            ),
          );
          when(
            () => mockRepository.getCompanyParameters(tCompany2.companyId),
          ).thenAnswer(
            (_) async => SuccessState(
              data: UserFactory.makeCompanyParameterEntity().copyWith(
                allowProviderCreateWorkOrder: true,
              ),
            ),
          );

          final result = await canProviderCreateWorkOrderUseCase(
            CanProviderCreateWorkOrderParams(
              companies: [tCompany1, tCompany2],
            ),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRepository.getCompanyParameters(tCompany1.companyId),
          ).called(1);
          verify(
            () => mockRepository.getCompanyParameters(tCompany2.companyId),
          ).called(1);
        },
      );

      test(
        'returns false when multiple companies and none allows it',
        () async {
          when(
            () => mockRepository.getCompanyParameters(any()),
          ).thenAnswer(
            (_) async => SuccessState(
              data: UserFactory.makeCompanyParameterEntity().copyWith(
                allowProviderCreateWorkOrder: false,
              ),
            ),
          );

          final result = await canProviderCreateWorkOrderUseCase(
            CanProviderCreateWorkOrderParams(
              companies: [tCompany1, tCompany2],
            ),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isFalse);
        },
      );

      test(
        'returns false when getCompanyParameters fails',
        () async {
          when(
            () => mockRepository.getCompanyParameters(any()),
          ).thenAnswer(
            (_) async => FailureState(message: 'Error fetching parameters'),
          );

          final result = await canProviderCreateWorkOrderUseCase(
            CanProviderCreateWorkOrderParams(companies: [tCompany1]),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isFalse);
        },
      );
    });

    group('CheckWorkOrderQuotaUseCase', () {
      late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
      late MockGetCompanyParametersUseCase mockGetCompanyParametersUseCase;
      late MockWorkOrdersRepository mockWorkOrdersRepository;
      late CheckWorkOrderQuotaUseCase checkWorkOrderQuotaUseCase;

      setUp(() {
        mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();
        mockGetCompanyParametersUseCase = MockGetCompanyParametersUseCase();
        mockWorkOrdersRepository = MockWorkOrdersRepository();

        checkWorkOrderQuotaUseCase = CheckWorkOrderQuotaUseCase(
          getActiveCompanyIdUseCase: mockGetActiveCompanyIdUseCase,
          getCompanyParametersUseCase: mockGetCompanyParametersUseCase,
          workOrdersRepository: mockWorkOrdersRepository,
        );

        when(() => mockGetActiveCompanyIdUseCase()).thenReturn(tCompanyId);
      });

      test('returns true when maxDailyWorkOrders is 0 (unlimited)', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxDailyWorkOrders: 0,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));

        final result = await checkWorkOrderQuotaUseCase();

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verifyZeroInteractions(mockWorkOrdersRepository);
      });

      test('returns true when today count is strictly below limit', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxDailyWorkOrders: 3,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));
        when(() => mockWorkOrdersRepository.countTodayWorkOrders(tCompanyId))
            .thenAnswer((_) async => const SuccessState(data: 2));

        final result = await checkWorkOrderQuotaUseCase();

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockWorkOrdersRepository.countTodayWorkOrders(tCompanyId))
            .called(1);
      });

      test('returns false when today count is exactly at limit', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxDailyWorkOrders: 3,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));
        when(() => mockWorkOrdersRepository.countTodayWorkOrders(tCompanyId))
            .thenAnswer((_) async => const SuccessState(data: 3));

        final result = await checkWorkOrderQuotaUseCase();

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
      });

      test('returns false when today count exceeds limit', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxDailyWorkOrders: 3,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));
        when(() => mockWorkOrdersRepository.countTodayWorkOrders(tCompanyId))
            .thenAnswer((_) async => const SuccessState(data: 4));

        final result = await checkWorkOrderQuotaUseCase();

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
      });

      test('returns FailureState when getCompanyParameters fails', () async {
        when(() => mockGetCompanyParametersUseCase(tCompanyId)).thenAnswer(
          (_) async => FailureState(message: 'Parameters fetch error'),
        );

        final result = await checkWorkOrderQuotaUseCase();

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Parameters fetch error');
        verifyZeroInteractions(mockWorkOrdersRepository);
      });

      test('returns FailureState when countTodayWorkOrders fails', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxDailyWorkOrders: 3,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));
        when(() => mockWorkOrdersRepository.countTodayWorkOrders(tCompanyId))
            .thenAnswer((_) async => FailureState(message: 'Count error'));

        final result = await checkWorkOrderQuotaUseCase();

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Count error');
      });
    });

    group('CheckAttachmentQuotaUseCase', () {
      late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
      late MockGetCompanyParametersUseCase mockGetCompanyParametersUseCase;
      late MockAttachmentsRepository mockAttachmentsRepository;
      late CheckAttachmentQuotaUseCase checkAttachmentQuotaUseCase;
      const tWorkOrderId = 'wo-123';

      setUp(() {
        mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();
        mockGetCompanyParametersUseCase = MockGetCompanyParametersUseCase();
        mockAttachmentsRepository = MockAttachmentsRepository();

        checkAttachmentQuotaUseCase = CheckAttachmentQuotaUseCase(
          getActiveCompanyIdUseCase: mockGetActiveCompanyIdUseCase,
          getCompanyParametersUseCase: mockGetCompanyParametersUseCase,
          attachmentsRepository: mockAttachmentsRepository,
        );

        when(() => mockGetActiveCompanyIdUseCase()).thenReturn(tCompanyId);
      });

      test('returns true when maxAttachmentsPerWorkOrder is 0 (unlimited)', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxAttachmentsPerWorkOrder: 0,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));

        final result = await checkAttachmentQuotaUseCase(
          const CheckAttachmentQuotaParams(workOrderId: tWorkOrderId),
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verifyZeroInteractions(mockAttachmentsRepository);
      });

      test('uses currentCount when provided: returns true when below limit', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxAttachmentsPerWorkOrder: 2,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));

        final result = await checkAttachmentQuotaUseCase(
          const CheckAttachmentQuotaParams(
            workOrderId: tWorkOrderId,
            currentCount: 1,
          ),
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verifyZeroInteractions(mockAttachmentsRepository);
      });

      test('uses currentCount when provided: returns false when at limit', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxAttachmentsPerWorkOrder: 2,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));

        final result = await checkAttachmentQuotaUseCase(
          const CheckAttachmentQuotaParams(
            workOrderId: tWorkOrderId,
            currentCount: 2,
          ),
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
        verifyZeroInteractions(mockAttachmentsRepository);
      });

      test('fetches from repository when currentCount is null', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxAttachmentsPerWorkOrder: 2,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));
        when(() => mockAttachmentsRepository.getAttachmentsByWorkOrder(tWorkOrderId))
            .thenAnswer((_) async => SuccessState(
                  data: [MaintenancePlanFactory.makeAttachmentEntity()],
                ));

        final result = await checkAttachmentQuotaUseCase(
          const CheckAttachmentQuotaParams(workOrderId: tWorkOrderId),
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockAttachmentsRepository.getAttachmentsByWorkOrder(tWorkOrderId))
            .called(1);
      });

      test('returns FailureState when repository fails and currentCount is null', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxAttachmentsPerWorkOrder: 2,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));
        when(() => mockAttachmentsRepository.getAttachmentsByWorkOrder(tWorkOrderId))
            .thenAnswer((_) async => FailureState(message: 'Attachment fetch failed'));

        final result = await checkAttachmentQuotaUseCase(
          const CheckAttachmentQuotaParams(workOrderId: tWorkOrderId),
        );

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Attachment fetch failed');
      });

      test('returns FailureState when getCompanyParameters fails', () async {
        when(() => mockGetCompanyParametersUseCase(tCompanyId)).thenAnswer(
          (_) async => FailureState(message: 'Parameters failed'),
        );

        final result = await checkAttachmentQuotaUseCase(
          const CheckAttachmentQuotaParams(workOrderId: tWorkOrderId),
        );

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Parameters failed');
      });
    });

    group('CheckObservationQuotaUseCase', () {
      late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
      late MockGetCompanyParametersUseCase mockGetCompanyParametersUseCase;
      late MockWorkOrderObservationsRepository mockObservationsRepository;
      late CheckObservationQuotaUseCase checkObservationQuotaUseCase;
      const tWorkOrderId = 'wo-123';

      setUp(() {
        mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();
        mockGetCompanyParametersUseCase = MockGetCompanyParametersUseCase();
        mockObservationsRepository = MockWorkOrderObservationsRepository();

        checkObservationQuotaUseCase = CheckObservationQuotaUseCase(
          getActiveCompanyIdUseCase: mockGetActiveCompanyIdUseCase,
          getCompanyParametersUseCase: mockGetCompanyParametersUseCase,
          observationsRepository: mockObservationsRepository,
        );

        when(() => mockGetActiveCompanyIdUseCase()).thenReturn(tCompanyId);
      });

      test('returns true when maxObservationsPerWorkOrder is 0 (unlimited)', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxObservationsPerWorkOrder: 0,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));

        final result = await checkObservationQuotaUseCase(
          const CheckObservationQuotaParams(workOrderId: tWorkOrderId),
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verifyZeroInteractions(mockObservationsRepository);
      });

      test('uses currentCount when provided: returns true when below limit', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxObservationsPerWorkOrder: 2,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));

        final result = await checkObservationQuotaUseCase(
          const CheckObservationQuotaParams(
            workOrderId: tWorkOrderId,
            currentCount: 1,
          ),
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verifyZeroInteractions(mockObservationsRepository);
      });

      test('uses currentCount when provided: returns false when at limit', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxObservationsPerWorkOrder: 2,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));

        final result = await checkObservationQuotaUseCase(
          const CheckObservationQuotaParams(
            workOrderId: tWorkOrderId,
            currentCount: 2,
          ),
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
        verifyZeroInteractions(mockObservationsRepository);
      });

      test('fetches from repository when currentCount is null', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxObservationsPerWorkOrder: 2,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));
        when(() => mockObservationsRepository.getObservations(tWorkOrderId))
            .thenAnswer((_) async => SuccessState(
                  data: [WorkOrderFactory.makeWorkOrderObservationEntity()],
                ));

        final result = await checkObservationQuotaUseCase(
          const CheckObservationQuotaParams(workOrderId: tWorkOrderId),
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockObservationsRepository.getObservations(tWorkOrderId))
            .called(1);
      });

      test('returns FailureState when repository fails and currentCount is null', () async {
        final params = UserFactory.makeCompanyParameterEntity().copyWith(
          maxObservationsPerWorkOrder: 2,
        );
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: params));
        when(() => mockObservationsRepository.getObservations(tWorkOrderId))
            .thenAnswer((_) async => FailureState(message: 'Observation fetch failed'));

        final result = await checkObservationQuotaUseCase(
          const CheckObservationQuotaParams(workOrderId: tWorkOrderId),
        );

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Observation fetch failed');
      });

      test('returns FailureState when getCompanyParameters fails', () async {
        when(() => mockGetCompanyParametersUseCase(tCompanyId)).thenAnswer(
          (_) async => FailureState(message: 'Parameters failed'),
        );

        final result = await checkObservationQuotaUseCase(
          const CheckObservationQuotaParams(workOrderId: tWorkOrderId),
        );

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Parameters failed');
      });
    });

    group('CheckFeatureEnabledUseCase', () {
      late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
      late MockGetCompanyUseCase mockGetCompanyUseCase;
      late MockGetCompanyParametersUseCase mockGetCompanyParametersUseCase;
      late CheckFeatureEnabledUseCase checkFeatureEnabledUseCase;

      setUp(() {
        mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();
        mockGetCompanyUseCase = MockGetCompanyUseCase();
        mockGetCompanyParametersUseCase = MockGetCompanyParametersUseCase();

        checkFeatureEnabledUseCase = CheckFeatureEnabledUseCase(
          getActiveCompanyIdUseCase: mockGetActiveCompanyIdUseCase,
          getCompanyUseCase: mockGetCompanyUseCase,
          getCompanyParametersUseCase: mockGetCompanyParametersUseCase,
        );

        when(() => mockGetActiveCompanyIdUseCase()).thenReturn(tCompanyId);
      });

      test('checks maintenancePlans: returns false for free company with default quota 0', () async {
        final freeCompany = tCompanyEntity.copyWith(planType: PlanType.free);
        final defaultParams = UserFactory.makeCompanyParameterEntity().copyWith(
          maxMaintenancePlans: 0,
        );

        when(() => mockGetCompanyUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: freeCompany));
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: defaultParams));

        final result = await checkFeatureEnabledUseCase(CompanyFeature.maintenancePlans);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
      });

      test('checks maintenancePlans: returns true for paid company even if maxMaintenancePlans is 0 (unlimited)', () async {
        final paidCompany = tCompanyEntity.copyWith(planType: PlanType.paid);
        final defaultParams = UserFactory.makeCompanyParameterEntity().copyWith(
          maxMaintenancePlans: 0,
        );

        when(() => mockGetCompanyUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: paidCompany));
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: defaultParams));

        final result = await checkFeatureEnabledUseCase(CompanyFeature.maintenancePlans);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
      });

      test('checks maintenancePlans: returns true for free company if custom limit > 0', () async {
        final freeCompany = tCompanyEntity.copyWith(planType: PlanType.free);
        final customParams = UserFactory.makeCompanyParameterEntity().copyWith(
          maxMaintenancePlans: 5,
        );

        when(() => mockGetCompanyUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: freeCompany));
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: customParams));

        final result = await checkFeatureEnabledUseCase(CompanyFeature.maintenancePlans);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
      });

      test('checks serviceProviders: returns false for free company with default quota 0', () async {
        final freeCompany = tCompanyEntity.copyWith(planType: PlanType.free);
        final defaultParams = UserFactory.makeCompanyParameterEntity().copyWith(
          maxServiceProviders: 0,
        );

        when(() => mockGetCompanyUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: freeCompany));
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: defaultParams));

        final result = await checkFeatureEnabledUseCase(CompanyFeature.serviceProviders);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
      });

      test('checks serviceProviders: returns true for paid company', () async {
        final paidCompany = tCompanyEntity.copyWith(planType: PlanType.paid);
        final defaultParams = UserFactory.makeCompanyParameterEntity().copyWith(
          maxServiceProviders: 0,
        );

        when(() => mockGetCompanyUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: paidCompany));
        when(() => mockGetCompanyParametersUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: defaultParams));

        final result = await checkFeatureEnabledUseCase(CompanyFeature.serviceProviders);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
      });

      test('returns FailureState when getCompanyUseCase fails', () async {
        when(() => mockGetCompanyUseCase(tCompanyId)).thenAnswer(
          (_) async => FailureState(message: 'Company fetch error'),
        );

        final result = await checkFeatureEnabledUseCase(CompanyFeature.maintenancePlans);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Company fetch error');
        verifyNever(() => mockGetCompanyParametersUseCase(any()));
      });

      test('returns FailureState when getCompanyParametersUseCase fails', () async {
        when(() => mockGetCompanyUseCase(tCompanyId))
            .thenAnswer((_) async => SuccessState(data: tCompanyEntity));
        when(() => mockGetCompanyParametersUseCase(tCompanyId)).thenAnswer(
          (_) async => FailureState(message: 'Params fetch error'),
        );

        final result = await checkFeatureEnabledUseCase(CompanyFeature.maintenancePlans);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Params fetch error');
      });
    });
  });
}

