import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/get_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/login_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/watch_session_use_case.dart';
import 'package:clean_architecture/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockLogOutUseCase extends Mock implements LogOutUseCase {}

class MockSetSessionUseCase extends Mock implements SetSessionUseCase {}

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

class MockGetUserDataUseCase extends Mock implements GetUserDataUseCase {}

class MockSaveUserDataUseCase extends Mock implements SaveUserDataUseCase {}

class MockCreateCompanyUseCase extends Mock implements CreateCompanyUseCase {}

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockWatchSessionUseCase extends Mock implements WatchSessionUseCase {}
