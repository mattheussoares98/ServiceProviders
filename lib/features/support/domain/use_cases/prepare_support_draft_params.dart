import 'package:equatable/equatable.dart';

class PrepareSupportDraftParams extends Equatable {
  const PrepareSupportDraftParams({
    required this.userDescription,
    required this.destinationEmail,
    required this.appName,
    required this.platformName,
    this.subjectPrefix = 'Suporte',
  });

  final String userDescription;
  final String destinationEmail;
  final String appName;
  final String platformName;
  final String subjectPrefix;

  @override
  List<Object?> get props => [
    userDescription,
    destinationEmail,
    appName,
    platformName,
    subjectPrefix,
  ];
}
