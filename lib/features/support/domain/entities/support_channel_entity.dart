import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_channel_type.dart';

class SupportChannelEntity extends Equatable {
  const SupportChannelEntity({
    required this.type,
    required this.destination,
    this.isAvailable = true,
    this.unavailableReason,
  });

  final SupportChannelType type;
  final String destination;
  final bool isAvailable;
  final String? unavailableReason;

  @override
  List<Object?> get props => [
    type,
    destination,
    isAvailable,
    unavailableReason,
  ];

  SupportChannelEntity copyWith({
    SupportChannelType? type,
    String? destination,
    bool? isAvailable,
    String? unavailableReason,
    bool? annulUnavailableReason,
  }) {
    return SupportChannelEntity(
      type: type ?? this.type,
      destination: destination ?? this.destination,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableReason: annulUnavailableReason == true
          ? null
          : unavailableReason ?? this.unavailableReason,
    );
  }
}
