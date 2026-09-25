import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

extension WorkTypeUiExtension on WorkType {
  String get label => switch (this) {
    WorkType.internalOnly => 'Interno'.hardcoded,
    WorkType.serviceProviderOnly => 'Prestador de serviços'.hardcoded,
    WorkType.hybrid => 'Ambos'.hardcoded,
  };

  String get description => switch (this) {
    WorkType.internalOnly =>
      'Manutenções em locais fixos da empresa (prédios, hospitais, fábricas, restaurantes, academias, lojas, mercados, etc)'
          .hardcoded,
    WorkType.serviceProviderOnly =>
      'Sua empresa atende clientes externos, sem local fixo'.hardcoded,
    WorkType.hybrid =>
      'Gerencia locais próprios e atende clientes externos'.hardcoded,
  };

  PlatformIcon get platformIcon => switch (this) {
    WorkType.internalOnly => const PlatformIcon(
      materialIcon: Icons.business_outlined,
      cupertinoIcon: CupertinoIcons.building_2_fill,
    ),
    WorkType.serviceProviderOnly => const PlatformIcon(
      materialIcon: Icons.handyman_outlined,
      cupertinoIcon: CupertinoIcons.hammer,
    ),
    WorkType.hybrid => const PlatformIcon(
      materialIcon: Icons.domain_add_outlined,
      cupertinoIcon: CupertinoIcons.layers_alt_fill,
    ),
  };
}
