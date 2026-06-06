import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'company_state.dart';

@injectable
class CompanyCubit extends BaseCubit<CompanyState> {
  CompanyCubit() : super(const CompanyState.empty());
}