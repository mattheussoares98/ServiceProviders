import 'package:equatable/equatable.dart';

class InviteUserParams extends Equatable {
  const InviteUserParams({
    required this.email,
    required this.companyId,
    required this.groupId,
  });

  final String email;
  final String companyId;
  final String groupId;

  @override
  List<Object?> get props => [email, companyId, groupId];
}
