import 'package:equatable/equatable.dart';

class SupportDraftMessageEntity extends Equatable {
  const SupportDraftMessageEntity({
    required this.subject,
    required this.body,
    required this.destination,
  });

  final String subject;
  final String body;
  final String destination;

  @override
  List<Object?> get props => [subject, body, destination];

  SupportDraftMessageEntity copyWith({
    String? subject,
    String? body,
    String? destination,
  }) {
    return SupportDraftMessageEntity(
      subject: subject ?? this.subject,
      body: body ?? this.body,
      destination: destination ?? this.destination,
    );
  }
}
