import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_model.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';

abstract interface class MaintenancePlansLocalDataSource {
  FutureList<MaintenancePlanModel> getPlans(String companyId);
  FutureData<MaintenancePlanModel> getPlanById(String id);
  FutureBool savePlan(MaintenancePlanModel plan);
  FutureBool deletePlan(String id);
}

@LazySingleton(as: MaintenancePlansLocalDataSource)
final class MaintenancePlansLocalDataSourceImpl
    implements MaintenancePlansLocalDataSource {
  MaintenancePlansLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureList<MaintenancePlanModel> getPlans(String companyId) {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.maintenancePlans)..where(
                (t) => t.companyId.equals(companyId) & t.deletedAt.isNull(),
              ))
              .get();

      return SuccessState(
        data: list
            .map(
              (t) => MaintenancePlanModel(
                id: t.id,
                companyId: t.companyId,
                assetId: t.assetId,
                locationId: t.locationId,
                title: t.title,
                description: t.description,
                frequency: Frequency.fromCode(t.frequency),
                dayOfWeek: t.dayOfWeek,
                dayOfMonth: t.dayOfMonth,
                monthOfYear: t.monthOfYear,
                checklistTemplateId: t.checklistTemplateId,
                assignedToId: t.assignedToId,
                priority: Priority.fromCode(t.priority),
                isActive: t.isActive,
                lastGeneratedAt: t.lastGeneratedAt?.toUtc(),
                nextDueDate: t.nextDueDate?.toUtc(),
                createdAt: t.createdAt.toUtc(),
                updatedAt: t.updatedAt.toUtc(),
                deletedAt: t.deletedAt?.toUtc(),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureData<MaintenancePlanModel> getPlanById(String id) {
    return ErrorHandler.execute(() async {
      final t =
          await (_database.select(_database.maintenancePlans)
                ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
              .getSingleOrNull();

      if (t != null) {
        return SuccessState(
          data: MaintenancePlanModel(
            id: t.id,
            companyId: t.companyId,
            assetId: t.assetId,
            locationId: t.locationId,
            title: t.title,
            description: t.description,
            frequency: Frequency.fromCode(t.frequency),
            dayOfWeek: t.dayOfWeek,
            dayOfMonth: t.dayOfMonth,
            monthOfYear: t.monthOfYear,
            checklistTemplateId: t.checklistTemplateId,
            assignedToId: t.assignedToId,
            priority: Priority.fromCode(t.priority),
            isActive: t.isActive,
            lastGeneratedAt: t.lastGeneratedAt?.toUtc(),
            nextDueDate: t.nextDueDate?.toUtc(),
            createdAt: t.createdAt.toUtc(),
            updatedAt: t.updatedAt.toUtc(),
            deletedAt: t.deletedAt?.toUtc(),
          ),
        );
      }

      return FailureState<MaintenancePlanModel>(
        message: 'Maintenance plan not found'.hardcoded,
      );
    });
  }

  @override
  FutureBool savePlan(MaintenancePlanModel plan) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.maintenancePlans)
          .insertOnConflictUpdate(
            MaintenancePlansCompanion(
              id: Value(plan.id),
              companyId: Value(plan.companyId),
              assetId: Value(plan.assetId),
              locationId: Value(plan.locationId),
              title: Value(plan.title),
              description: Value(plan.description),
              frequency: Value(plan.frequency.code),
              dayOfWeek: Value(plan.dayOfWeek),
              dayOfMonth: Value(plan.dayOfMonth),
              monthOfYear: Value(plan.monthOfYear),
              checklistTemplateId: Value(plan.checklistTemplateId),
              assignedToId: Value(plan.assignedToId),
              priority: Value(plan.priority.code),
              isActive: Value(plan.isActive),
              lastGeneratedAt: Value(plan.lastGeneratedAt),
              nextDueDate: Value(plan.nextDueDate),
              createdAt: Value(plan.createdAt),
              updatedAt: Value(plan.updatedAt),
              deletedAt: Value(plan.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deletePlan(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(_database.maintenancePlans)
            ..where((t) => t.id.equals(id)))
          .write(MaintenancePlansCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }
}
