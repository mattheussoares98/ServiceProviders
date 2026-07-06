import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';

extension AssetStatusX on AssetStatus {
  Color get color {
    switch (this) {
      case AssetStatus.active:
        return AppColors.success;
      case AssetStatus.inactive:
        return AppColors.warning;
      case AssetStatus.decommissioned:
        return AppColors.error;
    }
  }
}

extension AssetCriticalityX on AssetCriticality {
  Color get color {
    switch (this) {
      case AssetCriticality.low:
        return AppColors.green500;
      case AssetCriticality.medium:
        return AppColors.warning;
      case AssetCriticality.high:
        return Colors.orange;
      case AssetCriticality.missionCritical:
        return AppColors.error;
    }
  }
}
