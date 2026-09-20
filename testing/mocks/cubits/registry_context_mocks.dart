import 'package:bloc_test/bloc_test.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

class MockRegistryUsersCubit extends MockCubit<UsersState>
    implements UsersCubit {}

class MockRegistrySessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}
