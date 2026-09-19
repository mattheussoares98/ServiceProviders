import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_model.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/interval_unit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';

abstract interface class MaintenancePlansLocalDataSource {
  FutureList<MaintenancePlanModel> getPlans(String companyId);
  FutureData<MaintenancePlanModel> getPlanById(String id);
  FutureBool savePlan(MaintenancePlanModel plan);
  FutureBool savePlans(List<MaintenancePlanModel> plans);
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
                locationId: t.locationId,
                assetId: t.assetId,
                areaId: t.areaId,
                assignedToId: t.assignedToId,
                serviceProviderCompanyId: t.serviceProviderCompanyId,
                checklistTemplateId: t.checklistTemplateId,
                title: t.title,
                description: t.description,
                priority: Priority.fromCode(t.priority),
                price: t.price,
                currency: t.currency,
                intervalValue: t.intervalValue,
                intervalUnit: IntervalUnit.fromCode(t.intervalUnit),
                leadTimeDays: t.leadTimeDays,
                durationHours: t.durationHours,
                dayOfWeek: t.dayOfWeek,
                dayOfMonth: t.dayOfMonth,
                monthOfYear: t.monthOfYear,
                isActive: t.isActive,
                lastGeneratedAt: t.lastGeneratedAt?.toUtc(),
                lastGeneratedWorkOrderId: t.lastGeneratedWorkOrderId,
                lastError: t.lastError,
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
            locationId: t.locationId,
            assetId: t.assetId,
            areaId: t.areaId,
            assignedToId: t.assignedToId,
            serviceProviderCompanyId: t.serviceProviderCompanyId,
            checklistTemplateId: t.checklistTemplateId,
            title: t.title,
            description: t.description,
            priority: Priority.fromCode(t.priority),
            price: t.price,
            currency: t.currency,
            intervalValue: t.intervalValue,
            intervalUnit: IntervalUnit.fromCode(t.intervalUnit),
            leadTimeDays: t.leadTimeDays,
            durationHours: t.durationHours,
            dayOfWeek: t.dayOfWeek,
            dayOfMonth: t.dayOfMonth,
            monthOfYear: t.monthOfYear,
            isActive: t.isActive,
            lastGeneratedAt: t.lastGeneratedAt?.toUtc(),
            lastGeneratedWorkOrderId: t.lastGeneratedWorkOrderId,
            lastError: t.lastError,
            nextDueDate: t.nextDueDate?.toUtc(),
            createdAt: t.createdAt.toUtc(),
            updatedAt: t.updatedAt.toUtc(),
            deletedAt: t.deletedAt?.toUtc(),
          ),
        );
      }

      return FailureState<MaintenancePlanModel>(
        message: 'Plano de manutenção não encontrado'.hardcoded,
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
              locationId: Value(plan.locationId),
              assetId: Value(plan.assetId),
              areaId: Value(plan.areaId),
              assignedToId: Value(plan.assignedToId),
              serviceProviderCompanyId: Value(plan.serviceProviderCompanyId),
              checklistTemplateId: Value(plan.checklistTemplateId),
              title: Value(plan.title),
              description: Value(plan.description),
              priority: Value(plan.priority.code),
              price: Value(plan.price),
              currency: Value(plan.currency),
              intervalValue: Value(plan.intervalValue),
              intervalUnit: Value(plan.intervalUnit.code),
              leadTimeDays: Value(plan.leadTimeDays),
              durationHours: Value(plan.durationHours),
              dayOfWeek: Value(plan.dayOfWeek),
              dayOfMonth: Value(plan.dayOfMonth),
              monthOfYear: Value(plan.monthOfYear),
              isActive: Value(plan.isActive),
              lastGeneratedAt: Value(plan.lastGeneratedAt?.toUtc()),
              lastGeneratedWorkOrderId: Value(plan.lastGeneratedWorkOrderId),
              lastError: Value(plan.lastError),
              nextDueDate: Value(plan.nextDueDate?.toUtc()),
              createdAt: Value(plan.createdAt.toUtc()),
              updatedAt: Value(plan.updatedAt.toUtc()),
              deletedAt: Value(plan.deletedAt?.toUtc()),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool savePlans(List<MaintenancePlanModel> plans) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.maintenancePlans,
          plans.map(
            (plan) => MaintenancePlansCompanion(
              id: Value(plan.id),
              companyId: Value(plan.companyId),
              locationId: Value(plan.locationId),
              assetId: Value(plan.assetId),
              areaId: Value(plan.areaId),
              assignedToId: Value(plan.assignedToId),
              serviceProviderCompanyId: Value(plan.serviceProviderCompanyId),
              checklistTemplateId: Value(plan.checklistTemplateId),
              title: Value(plan.title),
              description: Value(plan.description),
              priority: Value(plan.priority.code),
              price: Value(plan.price),
              currency: Value(plan.currency),
              intervalValue: Value(plan.intervalValue),
              intervalUnit: Value(plan.intervalUnit.code),
              leadTimeDays: Value(plan.leadTimeDays),
              durationHours: Value(plan.durationHours),
              dayOfWeek: Value(plan.dayOfWeek),
              dayOfMonth: Value(plan.dayOfMonth),
              monthOfYear: Value(plan.monthOfYear),
              isActive: Value(plan.isActive),
              lastGeneratedAt: Value(plan.lastGeneratedAt?.toUtc()),
              lastGeneratedWorkOrderId: Value(plan.lastGeneratedWorkOrderId),
              lastError: Value(plan.lastError),
              nextDueDate: Value(plan.nextDueDate?.toUtc()),
              createdAt: Value(plan.createdAt.toUtc()),
              updatedAt: Value(plan.updatedAt.toUtc()),
              deletedAt: Value(plan.deletedAt?.toUtc()),
            ),
          ),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deletePlan(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(
        _database.maintenancePlans,
      )..where((t) => t.id.equals(id))).write(
        MaintenancePlansCompanion(deletedAt: Value(DateTime.now().toUtc())),
      );
      return const SuccessState(data: true);
    });
  }
}
