import 'package:equatable/equatable.dart';

class GetAccessLogsRequestEntity extends Equatable {
  const GetAccessLogsRequestEntity({
    required this.companyId,
    this.startDate,
    this.endDate,
    this.userId,
    this.limit = 50,
    this.offset = 0,
  });

  final String companyId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userId;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [
    companyId,
    startDate,
    endDate,
    userId,
    limit,
    offset,
  ];

  GetAccessLogsRequestEntity copyWith({
    String? companyId,
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    int? limit,
    int? offset,
    bool? annulStartDate,
    bool? annulEndDate,
    bool? annulUserId,
  }) {
    return GetAccessLogsRequestEntity(
      companyId: companyId ?? this.companyId,
      startDate: annulStartDate == true ? null : startDate ?? this.startDate,
      endDate: annulEndDate == true ? null : endDate ?? this.endDate,
      userId: annulUserId == true ? null : userId ?? this.userId,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
