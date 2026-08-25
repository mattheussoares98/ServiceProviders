import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/repositories/users_repository.dart';

@LazySingleton()
class WatchUserProfilesRealtimeUseCase {
  const WatchUserProfilesRealtimeUseCase({
    required UsersRepository usersRepository,
  }) : _usersRepository = usersRepository;

  final UsersRepository _usersRepository;

  Stream<RealtimeEvent<UserProfileEntity>> call({String? companyId}) =>
      _usersRepository.watchUserProfilesRealtime(companyId: companyId);
}
