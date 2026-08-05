import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/create_area_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/create_location_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/delete_area_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/delete_location_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_areas_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_locations_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/update_area_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/update_location_use_case.dart';

@LazySingleton()
class LocationsCubitUseCases {
  const LocationsCubitUseCases({
    required this.getActiveCompanyId,
    required this.getLocations,
    required this.getAreas,
    required this.createLocation,
    required this.updateLocation,
    required this.deleteLocation,
    required this.createArea,
    required this.updateArea,
    required this.deleteArea,
  });

  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetLocationsUseCase getLocations;
  final GetAreasUseCase getAreas;
  final CreateLocationUseCase createLocation;
  final UpdateLocationUseCase updateLocation;
  final DeleteLocationUseCase deleteLocation;
  final CreateAreaUseCase createArea;
  final UpdateAreaUseCase updateArea;
  final DeleteAreaUseCase deleteArea;
}
