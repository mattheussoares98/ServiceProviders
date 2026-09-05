import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_order.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/models/requests/create_access_log_request_model.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/models/responses/access_log_model.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/get_access_logs_request_entity.dart';

abstract interface class AccessLogsRemoteDataSource {
  FutureList<AccessLogModel> getAccessLogs(GetAccessLogsRequestEntity request);
  FutureVoid createAccessLog(CreateAccessLogRequestModel request);
}

@LazySingleton(as: AccessLogsRemoteDataSource)
final class AccessLogsRemoteDataSourceImpl
    implements AccessLogsRemoteDataSource {
  const AccessLogsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<AccessLogModel> getAccessLogs(
    GetAccessLogsRequestEntity request,
  ) => SupabaseHandler.call(() async {
    final filters = <SupabaseFilter>[
      SupabaseFilter.eq('company_id', request.companyId),
    ];

    if (request.userId != null && request.userId!.isNotEmpty) {
      filters.add(SupabaseFilter.eq('user_id', request.userId!));
    }

    if (request.startDate != null) {
      filters.add(
        SupabaseFilter.gte('created_at', request.startDate!.toIsoUtcString()),
      );
    }

    if (request.endDate != null) {
      filters.add(
        SupabaseFilter.lte('created_at', request.endDate!.toIsoUtcString()),
      );
    }

    final response = await _database.selectList(
      table: 'access_logs',
      columns: '*, user_profiles(name, email)',
      filters: filters,
      orderBy: const [SupabaseOrder(column: 'created_at')],
      limit: request.limit,
      offset: request.offset,
    );

    return response.map(AccessLogModel.fromJson).toList();
  });

  @override
  FutureVoid createAccessLog(CreateAccessLogRequestModel request) =>
      SupabaseHandler.voidCall(() async {
        await _database.insert(table: 'access_logs', values: request.toJson());
      });
}
