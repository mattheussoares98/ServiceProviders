// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:clean_architecture/config/app_config.dart' as _i37;
import 'package:clean_architecture/core/clients/local/drift/app_database.dart'
    as _i144;
import 'package:clean_architecture/core/clients/local/local_storage_client.dart'
    as _i1009;
import 'package:clean_architecture/core/clients/remote/http/http_client.dart'
    as _i244;
import 'package:clean_architecture/core/clients/remote/internet_client.dart'
    as _i9;
import 'package:clean_architecture/core/clients/remote/supabase/supabase_auth_client.dart'
    as _i432;
import 'package:clean_architecture/core/clients/remote/supabase_module.dart'
    as _i499;
import 'package:clean_architecture/features/assets/data/data_sources/assets_local_data_source.dart'
    as _i262;
import 'package:clean_architecture/features/assets/data/data_sources/assets_remote_data_source.dart'
    as _i463;
import 'package:clean_architecture/features/assets/data/repositories/assets_repository_impl.dart'
    as _i771;
import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart'
    as _i921;
import 'package:clean_architecture/features/assets/domain/use_cases/get_assets_use_case.dart'
    as _i948;
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart'
    as _i364;
import 'package:clean_architecture/features/attachments/data/data_sources/attachments_local_data_source.dart'
    as _i887;
import 'package:clean_architecture/features/attachments/data/data_sources/attachments_remote_data_source.dart'
    as _i536;
import 'package:clean_architecture/features/attachments/data/repositories/attachments_repository_impl.dart'
    as _i609;
import 'package:clean_architecture/features/attachments/domain/repositories/attachments_repository.dart'
    as _i412;
import 'package:clean_architecture/features/attachments/domain/use_cases/get_attachments_use_case.dart'
    as _i1061;
import 'package:clean_architecture/features/attachments/presentation/cubits/attachments/attachments_cubit.dart'
    as _i201;
import 'package:clean_architecture/features/auth/data/data_sources/auth_local_data_source.dart'
    as _i322;
import 'package:clean_architecture/features/auth/data/data_sources/auth_remote_data_source.dart'
    as _i141;
import 'package:clean_architecture/features/auth/data/data_sources/session_local_data_source.dart'
    as _i16;
import 'package:clean_architecture/features/auth/data/repositories/auth_repository_impl.dart'
    as _i526;
import 'package:clean_architecture/features/auth/data/repositories/session_repository_impl.dart'
    as _i943;
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart'
    as _i1003;
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart'
    as _i150;
import 'package:clean_architecture/features/auth/domain/use_cases/change_password_use_case.dart'
    as _i750;
import 'package:clean_architecture/features/auth/domain/use_cases/check_authentication_use_case.dart'
    as _i481;
import 'package:clean_architecture/features/auth/domain/use_cases/get_user_data_use_case.dart'
    as _i817;
import 'package:clean_architecture/features/auth/domain/use_cases/log_out_use_case.dart'
    as _i294;
import 'package:clean_architecture/features/auth/domain/use_cases/login_use_case.dart'
    as _i68;
import 'package:clean_architecture/features/auth/domain/use_cases/reset_password_use_case.dart'
    as _i701;
import 'package:clean_architecture/features/auth/domain/use_cases/set_session_use_case.dart'
    as _i636;
import 'package:clean_architecture/features/auth/domain/use_cases/sign_up_use_case.dart'
    as _i979;
import 'package:clean_architecture/features/auth/presentation/cubits/change_password/change_password_cubit.dart'
    as _i379;
import 'package:clean_architecture/features/auth/presentation/cubits/change_password/change_password_cubit_use_cases.dart'
    as _i456;
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit.dart'
    as _i912;
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit_use_cases.dart'
    as _i123;
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit.dart'
    as _i68;
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit_use_cases.dart'
    as _i735;
import 'package:clean_architecture/features/categories/data/data_sources/categories_local_data_source.dart'
    as _i335;
import 'package:clean_architecture/features/categories/data/data_sources/categories_remote_data_source.dart'
    as _i986;
import 'package:clean_architecture/features/categories/data/repositories/categories_repository_impl.dart'
    as _i223;
import 'package:clean_architecture/features/categories/domain/repositories/categories_repository.dart'
    as _i776;
import 'package:clean_architecture/features/categories/domain/use_cases/get_categories_use_case.dart'
    as _i449;
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit.dart'
    as _i950;
import 'package:clean_architecture/features/checklists/data/data_sources/checklists_local_data_source.dart'
    as _i787;
import 'package:clean_architecture/features/checklists/data/data_sources/checklists_remote_data_source.dart'
    as _i848;
import 'package:clean_architecture/features/checklists/data/repositories/checklists_repository_impl.dart'
    as _i536;
import 'package:clean_architecture/features/checklists/domain/repositories/checklists_repository.dart'
    as _i35;
import 'package:clean_architecture/features/checklists/domain/use_cases/get_checklists_use_case.dart'
    as _i909;
import 'package:clean_architecture/features/checklists/presentation/cubits/checklists/checklists_cubit.dart'
    as _i669;
import 'package:clean_architecture/features/company/data/data_sources/company_local_data_source.dart'
    as _i1017;
import 'package:clean_architecture/features/company/data/data_sources/company_remote_data_source.dart'
    as _i584;
import 'package:clean_architecture/features/company/data/repositories/company_repository_impl.dart'
    as _i117;
import 'package:clean_architecture/features/company/domain/repositories/company_repository.dart'
    as _i50;
import 'package:clean_architecture/features/company/domain/use_cases/get_company_parameters_use_case.dart'
    as _i270;
import 'package:clean_architecture/features/company/domain/use_cases/get_company_use_case.dart'
    as _i574;
import 'package:clean_architecture/features/company/domain/use_cases/save_company_parameters_use_case.dart'
    as _i261;
import 'package:clean_architecture/features/company/domain/use_cases/save_company_use_case.dart'
    as _i711;
import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit.dart'
    as _i1048;
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart'
    as _i471;
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit_use_cases.dart'
    as _i435;
import 'package:clean_architecture/features/locations/data/data_sources/locations_local_data_source.dart'
    as _i303;
import 'package:clean_architecture/features/locations/data/data_sources/locations_remote_data_source.dart'
    as _i468;
import 'package:clean_architecture/features/locations/data/repositories/locations_repository_impl.dart'
    as _i132;
import 'package:clean_architecture/features/locations/domain/repositories/locations_repository.dart'
    as _i478;
import 'package:clean_architecture/features/locations/domain/use_cases/get_locations_use_case.dart'
    as _i194;
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart'
    as _i343;
import 'package:clean_architecture/features/maintenance_plans/data/data_sources/maintenance_plans_local_data_source.dart'
    as _i866;
import 'package:clean_architecture/features/maintenance_plans/data/data_sources/maintenance_plans_remote_data_source.dart'
    as _i773;
import 'package:clean_architecture/features/maintenance_plans/data/repositories/maintenance_plans_repository_impl.dart'
    as _i151;
import 'package:clean_architecture/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart'
    as _i637;
import 'package:clean_architecture/features/maintenance_plans/domain/use_cases/get_maintenance_plans_use_case.dart'
    as _i158;
import 'package:clean_architecture/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit.dart'
    as _i534;
import 'package:clean_architecture/features/users/data/data_sources/users_local_data_source.dart'
    as _i3;
import 'package:clean_architecture/features/users/data/data_sources/users_remote_data_source.dart'
    as _i248;
import 'package:clean_architecture/features/users/data/repositories/users_repository_impl.dart'
    as _i635;
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart'
    as _i483;
import 'package:clean_architecture/features/users/domain/use_cases/get_users_use_case.dart'
    as _i945;
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart'
    as _i388;
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_local_data_source.dart'
    as _i689;
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_remote_data_source.dart'
    as _i622;
import 'package:clean_architecture/features/work_orders/data/repositories/work_orders_repository_impl.dart'
    as _i556;
import 'package:clean_architecture/features/work_orders/domain/repositories/work_orders_repository.dart'
    as _i126;
import 'package:clean_architecture/features/work_orders/domain/use_cases/get_work_orders_use_case.dart'
    as _i518;
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart'
    as _i370;
import 'package:clean_architecture/routing/helper/navigation_client.dart'
    as _i389;
import 'package:clean_architecture/routing/routes.dart' as _i671;
import 'package:clean_architecture/shared_ui/cubits/keyboard_visibility/keyboard_visibility_cubit.dart'
    as _i1037;
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart'
    as _i640;
import 'package:clean_architecture/shared_ui/cubits/theme/theme_cubit.dart'
    as _i368;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

const String _staging = 'staging';
const String _development = 'development';
const String _production = 'production';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> initialize({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final httpClientModule = _$HttpClientModule();
    final internetClientModule = _$InternetClientModule();
    final supabaseModule = _$SupabaseModule();
    final navigationClientModule = _$NavigationClientModule();
    final localStorageClientModule = _$LocalStorageClientModule();
    gh.factory<bool>(() => httpClientModule.addInterceptors);
    gh.factory<_i364.AssetsCubit>(() => _i364.AssetsCubit());
    gh.factory<_i201.AttachmentsCubit>(() => _i201.AttachmentsCubit());
    gh.factory<_i950.CategoriesCubit>(() => _i950.CategoriesCubit());
    gh.factory<_i669.ChecklistsCubit>(() => _i669.ChecklistsCubit());
    gh.factory<_i1048.CompanyCubit>(() => _i1048.CompanyCubit());
    gh.factory<_i343.LocationsCubit>(() => _i343.LocationsCubit());
    gh.factory<_i534.MaintenancePlansCubit>(
      () => _i534.MaintenancePlansCubit(),
    );
    gh.factory<_i388.UsersCubit>(() => _i388.UsersCubit());
    gh.factory<_i370.WorkOrdersCubit>(() => _i370.WorkOrdersCubit());
    gh.factory<_i1037.KeyboardVisibilityCubit>(
      () => _i1037.KeyboardVisibilityCubit(),
    );
    gh.factory<_i640.ScreenObserverCubit>(() => _i640.ScreenObserverCubit());
    gh.lazySingleton<_i144.AppDatabase>(() => _i144.AppDatabase());
    gh.lazySingleton<_i361.Dio>(() => httpClientModule.dio);
    gh.lazySingleton<_i244.HttpAuthInterceptor>(
      () => _i244.HttpAuthInterceptor(),
    );
    gh.lazySingleton<_i161.InternetConnection>(
      () => internetClientModule.internetConnection,
    );
    gh.lazySingleton<_i454.SupabaseClient>(() => supabaseModule.supabaseClient);
    gh.lazySingleton<_i454.GoTrueClient>(() => supabaseModule.supabaseAuth);
    gh.lazySingleton<_i671.AppRouter>(() => navigationClientModule.appRouter);
    gh.lazySingleton<_i37.AppConfig>(
      () => _i37.AppConfigStg(),
      registerFor: {_staging},
    );
    gh.lazySingleton<_i1017.CompanyLocalDataSource>(
      () =>
          _i1017.CompanyLocalDataSourceImpl(database: gh<_i144.AppDatabase>()),
    );
    gh.lazySingleton<_i432.SupabaseAuthClient>(
      () => _i432.SupabaseAuthClientImpl(gh<_i454.GoTrueClient>()),
    );
    await gh.factoryAsync<_i1009.LocalStorageClient>(
      () => localStorageClientModule.provideLocalStorageClient(
        gh<_i144.AppDatabase>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i9.InternetClient>(
      () => _i9.InternetClientImpl(
        internetConnection: gh<_i161.InternetConnection>(),
      ),
    );
    gh.lazySingleton<_i37.AppConfig>(
      () => _i37.AppConfigDev(),
      registerFor: {_development},
    );
    gh.lazySingleton<_i866.MaintenancePlansLocalDataSource>(
      () => _i866.MaintenancePlansLocalDataSourceImpl(
        localDatabase: gh<_i1009.LocalStorageClient>(),
      ),
    );
    gh.lazySingleton<_i262.AssetsLocalDataSource>(
      () => _i262.AssetsLocalDataSourceImpl(
        localDatabase: gh<_i1009.LocalStorageClient>(),
      ),
    );
    gh.lazySingleton<_i37.AppConfig>(
      () => _i37.AppConfigProd(),
      registerFor: {_production},
    );
    gh.lazySingleton<_i3.UsersLocalDataSource>(
      () => _i3.UsersLocalDataSourceImpl(
        localDatabase: gh<_i1009.LocalStorageClient>(),
      ),
    );
    gh.lazySingleton<_i389.NavigationClient>(
      () => _i389.NavigationClientImpl(appRouter: gh<_i671.AppRouter>()),
    );
    gh.lazySingleton<_i303.LocationsLocalDataSource>(
      () => _i303.LocationsLocalDataSourceImpl(
        localDatabase: gh<_i1009.LocalStorageClient>(),
      ),
    );
    gh.lazySingleton<_i141.AuthRemoteDataSource>(
      () => _i141.AuthRemoteDataSourceImpl(
        supabaseAuth: gh<_i432.SupabaseAuthClient>(),
      ),
    );
    gh.lazySingleton<_i335.CategoriesLocalDataSource>(
      () => _i335.CategoriesLocalDataSourceImpl(
        localDatabase: gh<_i1009.LocalStorageClient>(),
      ),
    );
    gh.factory<_i368.ThemeCubit>(
      () => _i368.ThemeCubit(gh<_i1009.LocalStorageClient>()),
    );
    gh.lazySingleton<_i16.SessionLocalDataSource>(
      () => _i16.SessionLocalDataSourceImpl(gh<_i1009.LocalStorageClient>()),
    );
    gh.lazySingleton<_i887.AttachmentsLocalDataSource>(
      () => _i887.AttachmentsLocalDataSourceImpl(
        localDatabase: gh<_i1009.LocalStorageClient>(),
      ),
    );
    gh.lazySingleton<_i689.WorkOrdersLocalDataSource>(
      () => _i689.WorkOrdersLocalDataSourceImpl(
        localDatabase: gh<_i1009.LocalStorageClient>(),
      ),
    );
    gh.lazySingleton<_i322.AuthLocalDataSource>(
      () => _i322.AuthLocalDataSourceImpl(
        localDatabase: gh<_i1009.LocalStorageClient>(),
      ),
    );
    gh.lazySingleton<_i787.ChecklistsLocalDataSource>(
      () => _i787.ChecklistsLocalDataSourceImpl(
        localDatabase: gh<_i1009.LocalStorageClient>(),
      ),
    );
    gh.lazySingleton<_i244.HttpClient>(
      () => _i244.HttpClientImpl(
        dio: gh<_i361.Dio>(),
        appConfig: gh<_i37.AppConfig>(),
        authInterceptor: gh<_i244.HttpAuthInterceptor>(),
        navigationClient: gh<_i389.NavigationClient>(),
        addInterceptors: gh<bool>(),
      ),
    );
    gh.lazySingleton<_i248.UsersRemoteDataSource>(
      () => _i248.UsersRemoteDataSourceImpl(httpClient: gh<_i244.HttpClient>()),
    );
    gh.lazySingleton<_i986.CategoriesRemoteDataSource>(
      () => _i986.CategoriesRemoteDataSourceImpl(
        httpClient: gh<_i244.HttpClient>(),
      ),
    );
    gh.lazySingleton<_i150.SessionRepository>(
      () => _i943.SessionRepositoryImpl(
        localDataSource: gh<_i16.SessionLocalDataSource>(),
        auth: gh<_i432.SupabaseAuthClient>(),
      ),
    );
    gh.lazySingleton<_i584.CompanyRemoteDataSource>(
      () =>
          _i584.CompanyRemoteDataSourceImpl(httpClient: gh<_i244.HttpClient>()),
    );
    gh.lazySingleton<_i468.LocationsRemoteDataSource>(
      () => _i468.LocationsRemoteDataSourceImpl(
        httpClient: gh<_i244.HttpClient>(),
      ),
    );
    gh.lazySingleton<_i1003.AuthRepository>(
      () => _i526.AuthRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i141.AuthRemoteDataSource>(),
        localDataSource: gh<_i322.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i622.WorkOrdersRemoteDataSource>(
      () => _i622.WorkOrdersRemoteDataSourceImpl(
        httpClient: gh<_i244.HttpClient>(),
      ),
    );
    gh.lazySingleton<_i536.AttachmentsRemoteDataSource>(
      () => _i536.AttachmentsRemoteDataSourceImpl(
        httpClient: gh<_i244.HttpClient>(),
      ),
    );
    gh.lazySingleton<_i50.CompanyRepository>(
      () => _i117.CompanyRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i584.CompanyRemoteDataSource>(),
        localDataSource: gh<_i1017.CompanyLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i294.LogOutUseCase>(
      () => _i294.LogOutUseCase(gh<_i150.SessionRepository>()),
    );
    gh.lazySingleton<_i636.SetSessionUseCase>(
      () => _i636.SetSessionUseCase(gh<_i150.SessionRepository>()),
    );
    gh.lazySingleton<_i750.ChangePasswordUseCase>(
      () =>
          _i750.ChangePasswordUseCase(repository: gh<_i1003.AuthRepository>()),
    );
    gh.lazySingleton<_i701.ResetPasswordUseCase>(
      () => _i701.ResetPasswordUseCase(repository: gh<_i1003.AuthRepository>()),
    );
    gh.lazySingleton<_i848.ChecklistsRemoteDataSource>(
      () => _i848.ChecklistsRemoteDataSourceImpl(
        httpClient: gh<_i244.HttpClient>(),
      ),
    );
    gh.lazySingleton<_i463.AssetsRemoteDataSource>(
      () =>
          _i463.AssetsRemoteDataSourceImpl(httpClient: gh<_i244.HttpClient>()),
    );
    gh.lazySingleton<_i773.MaintenancePlansRemoteDataSource>(
      () => _i773.MaintenancePlansRemoteDataSourceImpl(
        httpClient: gh<_i244.HttpClient>(),
      ),
    );
    gh.lazySingleton<_i637.MaintenancePlansRepository>(
      () => _i151.MaintenancePlansRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i773.MaintenancePlansRemoteDataSource>(),
        localDataSource: gh<_i866.MaintenancePlansLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i481.CheckAuthenticationUseCase>(
      () => _i481.CheckAuthenticationUseCase(
        authRepository: gh<_i1003.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i817.GetUserDataUseCase>(
      () =>
          _i817.GetUserDataUseCase(authRepository: gh<_i1003.AuthRepository>()),
    );
    gh.lazySingleton<_i68.LoginUseCase>(
      () => _i68.LoginUseCase(authRepository: gh<_i1003.AuthRepository>()),
    );
    gh.lazySingleton<_i979.SignUpUseCase>(
      () => _i979.SignUpUseCase(authRepository: gh<_i1003.AuthRepository>()),
    );
    gh.lazySingleton<_i483.UsersRepository>(
      () => _i635.UsersRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i248.UsersRemoteDataSource>(),
        localDataSource: gh<_i3.UsersLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i126.WorkOrdersRepository>(
      () => _i556.WorkOrdersRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i622.WorkOrdersRemoteDataSource>(),
        localDataSource: gh<_i689.WorkOrdersLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i478.LocationsRepository>(
      () => _i132.LocationsRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i468.LocationsRemoteDataSource>(),
        localDataSource: gh<_i303.LocationsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i945.GetUsersUseCase>(
      () => _i945.GetUsersUseCase(usersRepository: gh<_i483.UsersRepository>()),
    );
    gh.lazySingleton<_i435.HomeCubitUseCases>(
      () => _i435.HomeCubitUseCases(logOut: gh<_i294.LogOutUseCase>()),
    );
    gh.lazySingleton<_i412.AttachmentsRepository>(
      () => _i609.AttachmentsRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i536.AttachmentsRemoteDataSource>(),
        localDataSource: gh<_i887.AttachmentsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i35.ChecklistsRepository>(
      () => _i536.ChecklistsRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i848.ChecklistsRemoteDataSource>(),
        localDataSource: gh<_i787.ChecklistsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i158.GetMaintenancePlansUseCase>(
      () => _i158.GetMaintenancePlansUseCase(
        maintenancePlansRepository: gh<_i637.MaintenancePlansRepository>(),
      ),
    );
    gh.lazySingleton<_i776.CategoriesRepository>(
      () => _i223.CategoriesRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i986.CategoriesRemoteDataSource>(),
        localDataSource: gh<_i335.CategoriesLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i449.GetCategoriesUseCase>(
      () => _i449.GetCategoriesUseCase(
        categoriesRepository: gh<_i776.CategoriesRepository>(),
      ),
    );
    gh.lazySingleton<_i270.GetCompanyParametersUseCase>(
      () => _i270.GetCompanyParametersUseCase(
        companyRepository: gh<_i50.CompanyRepository>(),
      ),
    );
    gh.lazySingleton<_i574.GetCompanyUseCase>(
      () => _i574.GetCompanyUseCase(
        companyRepository: gh<_i50.CompanyRepository>(),
      ),
    );
    gh.lazySingleton<_i261.SaveCompanyParametersUseCase>(
      () => _i261.SaveCompanyParametersUseCase(
        companyRepository: gh<_i50.CompanyRepository>(),
      ),
    );
    gh.lazySingleton<_i711.SaveCompanyUseCase>(
      () => _i711.SaveCompanyUseCase(
        companyRepository: gh<_i50.CompanyRepository>(),
      ),
    );
    gh.lazySingleton<_i909.GetChecklistsUseCase>(
      () => _i909.GetChecklistsUseCase(
        checklistsRepository: gh<_i35.ChecklistsRepository>(),
      ),
    );
    gh.lazySingleton<_i921.AssetsRepository>(
      () => _i771.AssetsRepositoryImpl(
        internet: gh<_i9.InternetClient>(),
        remoteDataSource: gh<_i463.AssetsRemoteDataSource>(),
        localDataSource: gh<_i262.AssetsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i456.ChangePasswordCubitUseCases>(
      () => _i456.ChangePasswordCubitUseCases(
        changePassword: gh<_i750.ChangePasswordUseCase>(),
      ),
    );
    gh.factory<_i471.HomeCubit>(
      () => _i471.HomeCubit(useCases: gh<_i435.HomeCubitUseCases>()),
    );
    gh.lazySingleton<_i194.GetLocationsUseCase>(
      () => _i194.GetLocationsUseCase(
        locationsRepository: gh<_i478.LocationsRepository>(),
      ),
    );
    gh.factory<_i379.ChangePasswordCubit>(
      () => _i379.ChangePasswordCubit(
        useCases: gh<_i456.ChangePasswordCubitUseCases>(),
      ),
    );
    gh.lazySingleton<_i735.SignUpCubitUseCases>(
      () => _i735.SignUpCubitUseCases(signUp: gh<_i979.SignUpUseCase>()),
    );
    gh.lazySingleton<_i123.LoginCubitUseCases>(
      () => _i123.LoginCubitUseCases(
        login: gh<_i68.LoginUseCase>(),
        logOut: gh<_i294.LogOutUseCase>(),
        resetPassword: gh<_i701.ResetPasswordUseCase>(),
        setSession: gh<_i636.SetSessionUseCase>(),
        getUserData: gh<_i817.GetUserDataUseCase>(),
      ),
    );
    gh.lazySingleton<_i518.GetWorkOrdersUseCase>(
      () => _i518.GetWorkOrdersUseCase(
        workOrdersRepository: gh<_i126.WorkOrdersRepository>(),
      ),
    );
    gh.lazySingleton<_i1061.GetAttachmentsUseCase>(
      () => _i1061.GetAttachmentsUseCase(
        attachmentsRepository: gh<_i412.AttachmentsRepository>(),
      ),
    );
    gh.lazySingleton<_i948.GetAssetsUseCase>(
      () => _i948.GetAssetsUseCase(
        assetsRepository: gh<_i921.AssetsRepository>(),
      ),
    );
    gh.factory<_i912.LoginCubit>(
      () => _i912.LoginCubit(useCases: gh<_i123.LoginCubitUseCases>()),
    );
    gh.factory<_i68.SignUpCubit>(
      () => _i68.SignUpCubit(useCases: gh<_i735.SignUpCubitUseCases>()),
    );
    return this;
  }
}

class _$HttpClientModule extends _i244.HttpClientModule {}

class _$InternetClientModule extends _i9.InternetClientModule {}

class _$SupabaseModule extends _i499.SupabaseModule {}

class _$NavigationClientModule extends _i389.NavigationClientModule {}

class _$LocalStorageClientModule extends _i1009.LocalStorageClientModule {}
