import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/categories/domain/use_cases/create_category_use_case.dart';
import 'package:o_jogo_da_obra/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:o_jogo_da_obra/features/categories/domain/use_cases/get_categories_use_case.dart';
import 'package:o_jogo_da_obra/features/categories/domain/use_cases/update_category_use_case.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockCreateCategoryUseCase extends Mock implements CreateCategoryUseCase {}

class MockUpdateCategoryUseCase extends Mock implements UpdateCategoryUseCase {}

class MockDeleteCategoryUseCase extends Mock implements DeleteCategoryUseCase {}

class MockGetActiveCompanyIdUseCase extends Mock
    implements GetActiveCompanyIdUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockCreateCategoryUseCase mockCreateCategory;
  late MockUpdateCategoryUseCase mockUpdateCategory;
  late MockDeleteCategoryUseCase mockDeleteCategory;
  late MockNavigationClient mockNavigationClient;
  late CategoryEntity tCategory;

  late CategoriesCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeCategoryEntity());
    registerFallbackValue(CreateUpdateCategoryRoute());
  });

  setUp(() {
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockCreateCategory = MockCreateCategoryUseCase();
    mockUpdateCategory = MockUpdateCategoryUseCase();
    mockDeleteCategory = MockDeleteCategoryUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();
    tCategory = EntityFactory.makeCategoryEntity();
    when(
      () => mockGetActiveCompanyId.call(),
    ).thenReturn(tUserProfile.companyId);

    final useCases = CategoriesCubitUseCases(
      getActiveCompanyId: mockGetActiveCompanyId,
      getCategories: mockGetCategories,
      createCategory: mockCreateCategory,
      updateCategory: mockUpdateCategory,
      deleteCategory: mockDeleteCategory,
    );

    cubit = CategoriesCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('CategoriesCubit Tests', () {
    group('loadCategories', () {
      blocTest<CategoriesCubit, CategoriesState>(
        'should emit loading and loaded when categories load successfully',
        build: () {
          final tCategories = EntityFactory.makeCategoryEntityList();
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tCategories));
          return cubit;
        },
        act: (cubit) => cubit.loadCategories(),
        expect: () => [
          isA<CategoriesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.categories, 'categories', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
        verify: (_) {
          verify(
            () => mockGetCategories.call(tUserProfile.companyId),
          ).called(1);
        },
      );

      blocTest<CategoriesCubit, CategoriesState>(
        'should not emit loading when emitLoading is false',
        build: () {
          final tCategories = EntityFactory.makeCategoryEntityList();
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tCategories));
          return cubit;
        },
        act: (cubit) => cubit.loadCategories(emitLoading: false),
        expect: () => [
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.categories, 'categories', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
      );

      blocTest<CategoriesCubit, CategoriesState>(
        'should emit error status when companyId is empty',
        build: () {
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error message'));
          return cubit;
        },
        act: (cubit) => cubit.loadCategories(),
        expect: () => [
          isA<CategoriesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.categories, 'categories', isEmpty),
        ],
      );

      blocTest<CategoriesCubit, CategoriesState>(
        'should emit error and show error toast when loading fails',
        build: () {
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error message'));
          return cubit;
        },
        act: (cubit) => cubit.loadCategories(),
        expect: () => [
          isA<CategoriesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Error message'),
        ],
      );
    });

    group('saveCategory', () {
      blocTest<CategoriesCubit, CategoriesState>(
        'should emit saving, call createCategory and refresh on success',
        build: () {
          when(
            () => mockCreateCategory.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tCategory]));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.saveCategory(
            id: null,
            name: tCategory.name,
            description: tCategory.description,
            color: tCategory.color,
            createdAt: tCategory.createdAt,
          );
          expect(result, isTrue);
        },
        verify: (_) {
          final captured =
              verify(
                    () => mockCreateCategory.call(captureAny()),
                  ).captured.single
                  as CategoryEntity;
          expect(captured.id, isNotEmpty);
          expect(captured.companyId, tUserProfile.companyId);
          expect(captured.name, tCategory.name);
          expect(captured.description, tCategory.description);
          expect(captured.color, tCategory.color);
          expect(captured.createdAt, tCategory.createdAt);
        },
        expect: () => [
          isA<CategoriesState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.categories, 'categories', isNotEmpty),
        ],
      );

      blocTest<CategoriesCubit, CategoriesState>(
        'should emit saving, call updateCategory and refresh on success',
        build: () {
          when(
            () => mockUpdateCategory.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tCategory]));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.saveCategory(
            id: tCategory.id,
            name: tCategory.name,
            description: tCategory.description,
            color: tCategory.color,
            createdAt: tCategory.createdAt,
          );
          expect(result, isTrue);
        },
        verify: (_) {
          verify(
            () => mockUpdateCategory.call(
              tCategory.copyWith(companyId: tUserProfile.companyId),
            ),
          ).called(1);
          verify(
            () => mockGetCategories.call(tUserProfile.companyId),
          ).called(1);
        },
        expect: () => [
          isA<CategoriesState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.categories, 'categories', isNotEmpty),
        ],
      );

      blocTest<CategoriesCubit, CategoriesState>(
        'should emit error status when create returns false on save',
        build: () {
          when(
            () => mockCreateCategory.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: false));
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tCategory]));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.saveCategory(
            id: null,
            name: tCategory.name,
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<CategoriesState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<CategoriesState>().having(
            (s) => s.status,
            'status',
            StateStatus.loadingError,
          ),
        ],
      );

      blocTest<CategoriesCubit, CategoriesState>(
        'should emit error and show error toast when save fails',
        build: () {
          when(
            () => mockCreateCategory.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Save failed'));
          return cubit;
        },
        act: (cubit) => cubit.saveCategory(id: null, name: tCategory.name),
        expect: () => [
          isA<CategoriesState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Save failed'),
        ],
      );
    });

    group('deleteCategory', () {
      final tCategory = EntityFactory.makeCategoryEntity();
      final tId = tCategory.id;

      blocTest<CategoriesCubit, CategoriesState>(
        'should emit deleting, call deleteCategory and refresh on success',
        build: () {
          when(
            () => mockDeleteCategory.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.deleteCategory(tId),
        expect: () => [
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.deleting)
              .having((s) => s.deletingIds, 'deletingIds', {tId}),
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.deletingIds, 'deletingIds', {tId})
              .having((s) => s.categories, 'categories', isEmpty),
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.deletingIds, 'deletingIds', isEmpty)
              .having((s) => s.categories, 'categories', isEmpty),
        ],
      );

      blocTest<CategoriesCubit, CategoriesState>(
        'should emit error and show error toast when deletion fails',
        build: () {
          when(
            () => mockDeleteCategory.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Delete failed'));
          return cubit;
        },
        act: (cubit) => cubit.deleteCategory(tId),
        expect: () => [
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.deleting)
              .having((s) => s.deletingIds, 'deletingIds', {tId}),
          isA<CategoriesState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.deletingIds, 'deletingIds', isEmpty)
              .having((s) => s.errorMessage, 'errorMessage', 'Delete failed'),
        ],
      );
    });

    group('navigateToCreateUpdateCategory', () {
      test('should push route and load categories', () async {
        when(
          () => mockNavigationClient.pushRoute<CreateUpdateCategoryRouteArgs>(
            any(),
          ),
        ).thenAnswer((_) async {
          return null;
        });
        when(
          () => mockGetCategories.call(any()),
        ).thenAnswer((_) async => SuccessState(data: [tCategory]));

        await cubit.navigateToCreateUpdateCategory(category: tCategory);

        verify(
          () => mockNavigationClient.pushRoute<CreateUpdateCategoryRouteArgs>(
            any(),
          ),
        ).called(1);
        verify(() => mockGetCategories.call(tUserProfile.companyId)).called(1);
      });
    });
  });
}
