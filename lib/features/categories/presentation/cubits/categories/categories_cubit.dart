import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'categories_state.dart';

@injectable
class CategoriesCubit extends BaseCubit<CategoriesState> {
  CategoriesCubit() : super(const CategoriesState.empty());
}