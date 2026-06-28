import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter_operator.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_order.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SupabaseDatabaseClient {
  Future<MapDynamic?> selectOne({
    required String table,
    String columns = '*',
    List<SupabaseFilter> filters = const [],
  });

  Future<List<MapDynamic>> selectList({
    required String table,
    String columns = '*',
    List<SupabaseFilter> filters = const [],
    List<SupabaseOrder> orderBy = const [],
    int? limit,
  });

  Future<List<MapDynamic>> insert({
    required String table,
    required Object values,
    String columns = '*',
  });

  Future<List<MapDynamic>> update({
    required String table,
    required MapDynamic values,
    String columns = '*',
    List<SupabaseFilter> filters = const [],
  });

  Future<List<MapDynamic>> upsert({
    required String table,
    required Object values,
    String columns = '*',
    String? onConflict,
    bool ignoreDuplicates = false,
  });

  Future<List<MapDynamic>> delete({
    required String table,
    String columns = '*',
    List<SupabaseFilter> filters = const [],
  });

  Future<dynamic> rpc({
    required String functionName,
    MapDynamic? params,
    bool get = false,
  });

  Future<FunctionResponse> invokeFunction(
    String functionName, {
    required HttpMethod method,
    MapString? headers,
    Object? body,
  });
}

@LazySingleton(as: SupabaseDatabaseClient)
final class SupabaseDatabaseClientImpl implements SupabaseDatabaseClient {
  const SupabaseDatabaseClientImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<MapDynamic?> selectOne({
    required String table,
    String columns = '*',
    List<SupabaseFilter> filters = const [],
  }) async {
    final query = _applyFilters(_client.from(table).select(columns), filters);
    final response = await query.maybeSingle();
    if (response == null) return null;
    return MapDynamic.from(response);
  }

  @override
  Future<List<MapDynamic>> selectList({
    required String table,
    String columns = '*',
    List<SupabaseFilter> filters = const [],
    List<SupabaseOrder> orderBy = const [],
    int? limit,
  }) async {
    PostgrestTransformBuilder<PostgrestList> query = _applyFilters(
      _client.from(table).select(columns),
      filters,
    );
    query = _applyOrder(query, orderBy);
    if (limit != null) query = query.limit(limit);

    final response = await query;
    return _mapList(response);
  }

  @override
  Future<List<MapDynamic>> insert({
    required String table,
    required Object values,
    String columns = '*',
  }) async {
    final response = await _client.from(table).insert(values).select(columns);
    return _mapList(response);
  }

  @override
  Future<List<MapDynamic>> update({
    required String table,
    required MapDynamic values,
    String columns = '*',
    List<SupabaseFilter> filters = const [],
  }) async {
    final query = _applyFilters(_client.from(table).update(values), filters);
    final response = await query.select(columns);
    return _mapList(response);
  }

  @override
  Future<List<MapDynamic>> upsert({
    required String table,
    required Object values,
    String columns = '*',
    String? onConflict,
    bool ignoreDuplicates = false,
  }) async {
    final response = await _client
        .from(table)
        .upsert(
          values,
          onConflict: onConflict,
          ignoreDuplicates: ignoreDuplicates,
        )
        .select(columns);
    return _mapList(response);
  }

  @override
  Future<List<MapDynamic>> delete({
    required String table,
    String columns = '*',
    List<SupabaseFilter> filters = const [],
  }) async {
    final query = _applyFilters(_client.from(table).delete(), filters);
    final response = await query.select(columns);
    return _mapList(response);
  }

  @override
  Future<dynamic> rpc({
    required String functionName,
    MapDynamic? params,
    bool get = false,
  }) {
    return _client.rpc(functionName, params: params, get: get);
  }

  @override
  Future<FunctionResponse> invokeFunction(
    String functionName, {
    MapString? headers,
    Object? body,
    required HttpMethod method,
  }) {
    return _client.functions.invoke(
      functionName,
      headers: headers,
      body: body,
      method: method,
    );
  }

  PostgrestFilterBuilder<T> _applyFilters<T>(
    PostgrestFilterBuilder<T> query,
    List<SupabaseFilter> filters,
  ) {
    var currentQuery = query;
    for (final filter in filters) {
      currentQuery = switch (filter.operator) {
        SupabaseFilterOperator.eq => currentQuery.eq(
          filter.column,
          filter.value!,
        ),
        SupabaseFilterOperator.neq => currentQuery.neq(
          filter.column,
          filter.value!,
        ),
        SupabaseFilterOperator.gt => currentQuery.gt(
          filter.column,
          filter.value!,
        ),
        SupabaseFilterOperator.gte => currentQuery.gte(
          filter.column,
          filter.value!,
        ),
        SupabaseFilterOperator.lt => currentQuery.lt(
          filter.column,
          filter.value!,
        ),
        SupabaseFilterOperator.lte => currentQuery.lte(
          filter.column,
          filter.value!,
        ),
        SupabaseFilterOperator.like => currentQuery.like(
          filter.column,
          filter.value! as String,
        ),
        SupabaseFilterOperator.ilike => currentQuery.ilike(
          filter.column,
          filter.value! as String,
        ),
        SupabaseFilterOperator.inList => currentQuery.inFilter(
          filter.column,
          filter.value! as List,
        ),
        SupabaseFilterOperator.isFilter => currentQuery.isFilter(
          filter.column,
          filter.value as bool?,
        ),
      };
    }
    return currentQuery;
  }

  PostgrestTransformBuilder<T> _applyOrder<T>(
    PostgrestTransformBuilder<T> query,
    List<SupabaseOrder> orderBy,
  ) {
    var currentQuery = query;
    for (final order in orderBy) {
      currentQuery = currentQuery.order(
        order.column,
        ascending: order.ascending,
        nullsFirst: order.nullsFirst,
        referencedTable: order.referencedTable,
      );
    }
    return currentQuery;
  }

  List<MapDynamic> _mapList(Object? response) {
    if (response case final List<dynamic> rows) {
      return rows
          .map((row) => MapDynamic.from(row as Map<dynamic, dynamic>))
          .toList();
    }
    return const [];
  }
}
