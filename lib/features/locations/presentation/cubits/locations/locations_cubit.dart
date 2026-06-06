import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'locations_state.dart';

@injectable
class LocationsCubit extends BaseCubit<LocationsState> {
  LocationsCubit() : super(const LocationsState.empty());
}