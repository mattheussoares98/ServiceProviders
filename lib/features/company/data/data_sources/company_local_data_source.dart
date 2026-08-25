import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_parameter_model.dart';

abstract interface class CompanyLocalDataSource {
  FutureData<CompanyModel> getCompany(String id);
  FutureData<CompanyParameterModel> getCompanyParameters(String companyId);
  FutureBool saveCompany(CompanyModel company);
  FutureBool saveCompanyParameters(CompanyParameterModel parameters);
}

@LazySingleton(as: CompanyLocalDataSource)
final class CompanyLocalDataSourceImpl implements CompanyLocalDataSource {
  const CompanyLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureData<CompanyModel> getCompany(String id) {
    return ErrorHandler.execute(() async {
      final company = await (_database.select(
        _database.companies,
      )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

      if (company != null) {
        return SuccessState(
          data: CompanyModel(
            id: company.id,
            name: company.name,
            cnpj: company.cnpj,
            logoUrl: company.logoUrl,
            isActive: company.isActive,
            createdAt: company.createdAt.toUtc(),
            updatedAt: company.updatedAt.toUtc(),
            deletedAt: company.deletedAt?.toUtc(),
          ),
        );
      }
      return FailureState<CompanyModel>(
        message: 'Empresa não encontrada'.hardcoded,
      );
    });
  }

  @override
  FutureData<CompanyParameterModel> getCompanyParameters(String companyId) {
    return ErrorHandler.execute(() async {
      final params = await (_database.select(
        _database.companyParameters,
      )..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())).getSingleOrNull();

      if (params != null) {
        List<String> parseGroupIds(String raw) {
          try {
            return (jsonDecode(raw) as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const [];
          } catch (_) {
            return const [];
          }
        }

        return SuccessState(
          data: CompanyParameterModel(
            id: params.id,
            companyId: params.companyId,
            maxOfflineDurationHours: params.maxOfflineDurationHours,
            maxOfflinePendingRequests: params.maxOfflinePendingRequests,
            offlineAlertThrottleFrequency: params.offlineAlertThrottleFrequency,
            maxImageSizeMb: params.maxImageSizeMb,
            maxVideoSizeMb: params.maxVideoSizeMb,
            maxPdfSizeMb: params.maxPdfSizeMb,
            maxDocumentSizeMb: params.maxDocumentSizeMb,
            sandboxQuotaMb: params.sandboxQuotaMb,
            maxSyncAttempts: params.maxSyncAttempts,
            inviteExpiryHours: params.inviteExpiryHours,
            advanceWarningMinutes: params.advanceWarningMinutes,
            advanceWarningGroupIds: parseGroupIds(params.advanceWarningGroupIds),
            delayedNotificationIntervalMinutes:
                params.delayedNotificationIntervalMinutes,
            escalationGroupIds: parseGroupIds(params.escalationGroupIds),
            createdAt: params.createdAt.toUtc(),
            updatedAt: params.updatedAt.toUtc(),
            deletedAt: params.deletedAt?.toUtc(),
          ),
        );
      }
      return FailureState<CompanyParameterModel>(
        message: 'Parâmetros da empresa não encontrados'.hardcoded,
      );
    });
  }

  @override
  FutureBool saveCompany(CompanyModel company) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.companies)
          .insertOnConflictUpdate(
            CompaniesCompanion(
              id: Value(company.id),
              name: Value(company.name),
              cnpj: Value(company.cnpj),
              logoUrl: Value(company.logoUrl),
              isActive: Value(company.isActive),
              createdAt: Value(company.createdAt.toUtc()),
              updatedAt: Value(company.updatedAt.toUtc()),
              deletedAt: Value(company.deletedAt?.toUtc()),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveCompanyParameters(CompanyParameterModel parameters) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.companyParameters)
          .insertOnConflictUpdate(
            CompanyParametersCompanion(
              id: Value(parameters.id),
              companyId: Value(parameters.companyId),
              maxOfflineDurationHours: Value(
                parameters.maxOfflineDurationHours,
              ),
              maxOfflinePendingRequests: Value(
                parameters.maxOfflinePendingRequests,
              ),
              offlineAlertThrottleFrequency: Value(
                parameters.offlineAlertThrottleFrequency,
              ),
              maxImageSizeMb: Value(parameters.maxImageSizeMb),
              maxVideoSizeMb: Value(parameters.maxVideoSizeMb),
              maxPdfSizeMb: Value(parameters.maxPdfSizeMb),
              maxDocumentSizeMb: Value(parameters.maxDocumentSizeMb),
              sandboxQuotaMb: Value(parameters.sandboxQuotaMb),
              maxSyncAttempts: Value(parameters.maxSyncAttempts),
              inviteExpiryHours: Value(parameters.inviteExpiryHours),
              advanceWarningMinutes: Value(parameters.advanceWarningMinutes),
              advanceWarningGroupIds: Value(
                jsonEncode(parameters.advanceWarningGroupIds),
              ),
              delayedNotificationIntervalMinutes: Value(
                parameters.delayedNotificationIntervalMinutes,
              ),
              escalationGroupIds: Value(
                jsonEncode(parameters.escalationGroupIds),
              ),
              createdAt: Value(parameters.createdAt.toUtc()),
              updatedAt: Value(parameters.updatedAt.toUtc()),
              deletedAt: Value(parameters.deletedAt?.toUtc()),
            ),
          );
      return const SuccessState(data: true);
    });
  }
}
