import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'users_state.dart';

@injectable
class UsersCubit extends BaseCubit<UsersState> {
  UsersCubit() : super(const UsersState.empty());
}