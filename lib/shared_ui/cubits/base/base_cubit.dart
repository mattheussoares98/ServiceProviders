import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/client_mixin.dart';

enum StateStatus {
  initial,
  loading,
  loadingError,
  loaded,
  noInternet,
  deleting,
  deletingError,
  saving,
  savingError,
}

abstract class BaseState extends Equatable {
  const BaseState({this.status = StateStatus.initial, this.errorMessage});
  final StateStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}

abstract class BaseCubit<T> extends Cubit<T> with ClientMixin {
  BaseCubit(super.initialState);
}
