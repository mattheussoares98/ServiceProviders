import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/repositories/users_repository.dart';
import 'package:path/path.dart' as p;

class UpdateUserAvatarParams extends Equatable {
  const UpdateUserAvatarParams({
    required this.userProfile,
    required this.localPath,
  });

  final UserProfileEntity userProfile;
  final String localPath;

  @override
  List<Object?> get props => [userProfile, localPath];
}

@LazySingleton()
class UpdateUserAvatarUseCase implements UseCase<bool, UpdateUserAvatarParams> {
  const UpdateUserAvatarUseCase({
    required StorageClient storageClient,
    required UsersRepository usersRepository,
    required SetSessionUseCase setSession,
    required SaveUserDataUseCase saveUserData,
    required SupabaseAuthClient authClient,
    required FileService fileService,
  })  : _storageClient = storageClient,
        _usersRepository = usersRepository,
        _setSession = setSession,
        _saveUserData = saveUserData,
        _authClient = authClient,
        _fileService = fileService;

  final StorageClient _storageClient;
  final UsersRepository _usersRepository;
  final SetSessionUseCase _setSession;
  final SaveUserDataUseCase _saveUserData;
  final SupabaseAuthClient _authClient;
  final FileService _fileService;

  @override
  FutureBool call(UpdateUserAvatarParams request) async {
    final userProfile = request.userProfile;
    final localPath = request.localPath;

    // Get extension and MIME type
    final ext = p.extension(localPath).replaceFirst('.', '').toLowerCase();
    final mimeType = _fileService.getMimeType(localPath);

    // Build object key satisfying: attachments/{companyId}/avatars/{userId}.{ext}
    final objectKey = 'attachments/${userProfile.companyId}/avatars/${userProfile.id}.$ext';

    // 1. Get presigned upload URL
    final presignedResult = await _storageClient.getPresignedUploadUrl(objectKey);
    if (presignedResult is! SuccessState<PresignedUrlResponse>) {
      return FailureState(
        message: (presignedResult as FailureState).message,
        error: presignedResult.error,
        statusCode: presignedResult.statusCode,
      );
    }
    final presigned = presignedResult.data!;

    // 2. Upload file bytes to R2
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

    // 3. Update the user profile
    final updatedProfile = userProfile.copyWith(avatarUrl: publicUrl);
    final updateResult = await _usersRepository.updateUserProfile(updatedProfile);
    if (updateResult is! SuccessState<bool>) {
      return updateResult;
    }

    // 4. Update the local session so UI reacts
    final session = _authClient.currentSession;
    final userData = UserDataEntity(
      user: updatedProfile,
      accessToken: session?.accessToken ?? '',
      refreshToken: session?.refreshToken ?? '',
    );
    _setSession.call(userData);
    await _saveUserData.call(userData);

    return const SuccessState(data: true);
  }
}
