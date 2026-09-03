import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter_operator.dart';

final class SupabaseFilter extends Equatable {
  const SupabaseFilter._({
    required this.column,
    required this.operator,
    required this.value,
  });

  factory SupabaseFilter.eq(String column, Object value) => SupabaseFilter._(
    column: column,
    operator: SupabaseFilterOperator.eq,
    value: value,
  );

  factory SupabaseFilter.neq(String column, Object value) => SupabaseFilter._(
    column: column,
    operator: SupabaseFilterOperator.neq,
    value: value,
  );

  factory SupabaseFilter.gt(String column, Object value) => SupabaseFilter._(
    column: column,
    operator: SupabaseFilterOperator.gt,
    value: value,
  );

  factory SupabaseFilter.gte(String column, Object value) => SupabaseFilter._(
    column: column,
    operator: SupabaseFilterOperator.gte,
    value: value,
  );

  factory SupabaseFilter.lt(String column, Object value) => SupabaseFilter._(
    column: column,
    operator: SupabaseFilterOperator.lt,
    value: value,
  );

  factory SupabaseFilter.lte(String column, Object value) => SupabaseFilter._(
    column: column,
    operator: SupabaseFilterOperator.lte,
    value: value,
  );

  factory SupabaseFilter.like(String column, String pattern) =>
      SupabaseFilter._(
        column: column,
        operator: SupabaseFilterOperator.like,
        value: pattern,
      );

  factory SupabaseFilter.ilike(String column, String pattern) =>
      SupabaseFilter._(
        column: column,
        operator: SupabaseFilterOperator.ilike,
        value: pattern,
      );

  factory SupabaseFilter.inList(String column, List<Object> values) =>
      SupabaseFilter._(
        column: column,
        operator: SupabaseFilterOperator.inList,
        value: values,
      );

  factory SupabaseFilter.isFilter(String column, bool? value) =>
      SupabaseFilter._(
        column: column,
        operator: SupabaseFilterOperator.isFilter,
        value: value,
      );

  factory SupabaseFilter.notFilter(
    String column,
    String operator,
    Object? value,
  ) => SupabaseFilter._(
    column: column,
    operator: SupabaseFilterOperator.notFilter,
    value: {'operator': operator, 'value': value},
  );

  final String column;
  final SupabaseFilterOperator operator;
  final Object? value;

  @override
  List<Object?> get props => [column, operator, value];
}
