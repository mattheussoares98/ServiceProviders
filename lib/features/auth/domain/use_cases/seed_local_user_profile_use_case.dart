import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/company/domain/repositories/company_repository.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

/// Temporary V1 use case: after login, seeds a local UserProfile and Company
/// row in Drift if they don't already exist. This bridges the gap until Phase 4
/// when Supabase provides the remote user_profiles table.
@LazySingleton()
class SeedLocalUserProfileUseCase {
  SeedLocalUserProfileUseCase({
    required UsersRepository usersRepository,
    required CompanyRepository companyRepository,
  }) : _usersRepository = usersRepository,
       _companyRepository = companyRepository;

  final UsersRepository _usersRepository;
  final CompanyRepository _companyRepository;

  /// Fixed company ID used for local testing in V1
  static const _defaultCompanyId = '1';

  FutureVoid call(UserDataEntity userData) async {
    final existingProfile = await _usersRepository.getUserProfileById(
      userData.user.id,
    );

    if (existingProfile is SuccessState) return SuccessState.nil;

    // Ensure a default company row exists
    final existingCompany = await _companyRepository.getCompany(
      _defaultCompanyId,
    );
    if (existingCompany is! SuccessState) {
      final now = DateTime.now();
      await _companyRepository.saveCompany(
        CompanyEntity(
          id: _defaultCompanyId,
          name: 'Empresa Teste',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // Create a local user profile from the auth data
    final now = DateTime.now();
    await _usersRepository.updateUserProfile(
      UserProfileEntity(
        id: userData.user.id,
        companyId: _defaultCompanyId,
        name: userData.user.name,
        email: userData.user.email,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return SuccessState.nil;
  }
}
