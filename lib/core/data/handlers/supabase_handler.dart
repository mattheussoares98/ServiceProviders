import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

abstract final class SupabaseHandler {
  /// Executes a Supabase Auth operation and returns a [DataState].
  static FutureData<T> call<T>(Future<T> Function() request) {
    return ErrorHandler.execute(() async {
      final result = await request();
      return SuccessState(data: result);
    });
  }

  /// Executes a Supabase Auth operation that returns void.
  static FutureVoid voidCall(Future<void> Function() request) {
    return ErrorHandler.execute(() async {
      await request();
      return SuccessState.nil;
    });
  }
}
