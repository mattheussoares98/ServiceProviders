import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_all_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/save_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/save_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/update_company_logo_use_case.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../testing/mocks/services.dart';

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
  });
}
