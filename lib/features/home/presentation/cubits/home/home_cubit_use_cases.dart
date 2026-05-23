import 'package:clean_architecture/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class HomeCubitUseCases {
  const HomeCubitUseCases({
    required this.logOut,
  });

  final LogOutUseCase logOut;
}
