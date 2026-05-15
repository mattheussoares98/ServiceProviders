import 'package:clean_architecture/core/utils/type_defs.dart';

abstract interface class UseCase<T, P extends Object?> {
  FutureData<T> call(P request);
}

abstract interface class UseCaseNoParameter<T> {
  FutureData<T> call();
}

abstract interface class UseCaseSynchronous<T, P extends Object?> {
  T call(P request);
}

abstract interface class UseCaseSynchronousNoParameter<T> {
  T call();
}
