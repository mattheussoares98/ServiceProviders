import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/repositories/company_repository.dart';
import 'package:path/path.dart' as p;

class UpdateCompanyLogoParams extends Equatable {
  const UpdateCompanyLogoParams({
    required this.company,
    required this.localPath,
  });

  final CompanyEntity company;
  final String localPath;

  @override
  List<Object?> get props => [company, localPath];
}

@LazySingleton()
class UpdateCompanyLogoUseCase
    implements UseCase<CompanyEntity, UpdateCompanyLogoParams> {
  const UpdateCompanyLogoUseCase({
    required StorageClient storageClient,
    required CompanyRepository companyRepository,
    required FileService fileService,
  }) : _storageClient = storageClient,
       _companyRepository = companyRepository,
       _fileService = fileService;

  final StorageClient _storageClient;
  final CompanyRepository _companyRepository;
  final FileService _fileService;

  @override
  FutureData<CompanyEntity> call(UpdateCompanyLogoParams request) async {
    final company = request.company;
    final localPath = request.localPath;

    final ext = p.extension(localPath).replaceFirst('.', '').toLowerCase();
    final mimeType = _fileService.getMimeType(localPath);

    final objectKey = 'attachments/${company.id}/logos/${company.id}.$ext';

    final presignedResult = await _storageClient.getPresignedUploadUrl(
      objectKey,
    );
    if (presignedResult is! SuccessState<PresignedUrlResponse>) {
      return FailureState(
        message: (presignedResult as FailureState).message,
        error: presignedResult.error,
        statusCode: presignedResult.statusCode,
      );
    }
    final presigned = presignedResult.data!;

    final uploadResult = await _storageClient.uploadFile(
      presignedUrl: presigned.uploadUrl,
      filePath: localPath,
      mimeType: mimeType,
    );
    if (uploadResult is! SuccessState<String>) {
      return FailureState(
        message: (uploadResult as FailureState).message,
        error: uploadResult.error,
        statusCode: uploadResult.statusCode,
      );
    }
    final publicUrl = presigned.publicUrl;

    final updatedCompany = company.copyWith(logoUrl: publicUrl);
    final saveResult = await _companyRepository.saveCompany(updatedCompany);
    if (saveResult is! SuccessState<bool> || saveResult.data != true) {
      return FailureState(
        message:
            (saveResult is FailureState)
                ? (saveResult as FailureState).message
                : 'Erro ao salvar empresa',
        error: (saveResult is FailureState) ? saveResult.error : null,
        statusCode:
            (saveResult is FailureState) ? saveResult.statusCode : null,
      );
    }

    return SuccessState(data: updatedCompany);
  }
}
