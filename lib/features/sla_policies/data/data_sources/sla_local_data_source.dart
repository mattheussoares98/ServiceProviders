import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/models/responses/sla_policy_model.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';

abstract interface class SlaLocalDataSource {
  FutureList<SlaPolicyModel> getSlaPolicies(String companyId);
  FutureData<SlaPolicyModel> getSlaPolicyById(String id);
  FutureBool saveSlaPolicy(SlaPolicyModel slaPolicy);
  FutureBool deleteSlaPolicy(String id);
}

@LazySingleton(as: SlaLocalDataSource)
final class SlaLocalDataSourceImpl implements SlaLocalDataSource {
  const SlaLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureList<SlaPolicyModel> getSlaPolicies(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.slaPolicies)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();
      final list = rows
          .map(
            (r) => SlaPolicyModel(
              id: r.id,
              companyId: r.companyId,
              name: r.name,
              targetHours: r.targetHours,
              appliesTo: SlaAppliesTo.fromValue(r.appliesTo),
              createdAt: r.createdAt.toUtc(),
              updatedAt: r.updatedAt.toUtc(),
              deletedAt: r.deletedAt?.toUtc(),
            ),
          )
          .toList();
      return SuccessState(data: list);
    });
  }

  @override
  FutureData<SlaPolicyModel> getSlaPolicyById(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.slaPolicies)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
      final r = await query.getSingleOrNull();
      if (r == null) {
        return FailureState(
          message: 'SLA não foi encontrado localmente'.hardcoded,
        );
      }
      final model = SlaPolicyModel(
        id: r.id,
        companyId: r.companyId,
        name: r.name,
        targetHours: r.targetHours,
        appliesTo: SlaAppliesTo.fromValue(r.appliesTo),
        createdAt: r.createdAt.toUtc(),
        updatedAt: r.updatedAt.toUtc(),
        deletedAt: r.deletedAt?.toUtc(),
      );
      return SuccessState(data: model);
    });
  }

  @override
  FutureBool saveSlaPolicy(SlaPolicyModel slaPolicy) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.slaPolicies)
          .insertOnConflictUpdate(
            SlaPoliciesCompanion(
              id: Value(slaPolicy.id),
              companyId: Value(slaPolicy.companyId),
              name: Value(slaPolicy.name),
              targetHours: Value(slaPolicy.targetHours),
              appliesTo: Value(slaPolicy.appliesTo.value),
              createdAt: Value(slaPolicy.createdAt),
              updatedAt: Value(slaPolicy.updatedAt),
              deletedAt: Value(slaPolicy.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteSlaPolicy(String id) {
    return ErrorHandler.execute(() async {
      final now = DateTime.now();
      await (_database.update(_database.slaPolicies)..where((t) => t.id.equals(id)))
          .write(SlaPoliciesCompanion(deletedAt: Value(now)));
      return const SuccessState(data: true);
    });
  }
}
