import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class CurrencyOption {
  //TODO move this file
  const CurrencyOption({
    required this.code,
    required this.label,
    required this.description,
    required this.symbol,
  });

  final String code;
  final String label;
  final String description;
  final String symbol;
}

class CurrencyConfigurationCard extends StatelessWidget {
  const CurrencyConfigurationCard({required this.parameters, super.key});

  final CompanyParameterEntity parameters;

  static final List<CurrencyOption> supportedCurrencies = [
    CurrencyOption(
      code: 'BRL',
      label: r'BRL (R$)'.hardcoded,
      description: 'Real brasileiro'.hardcoded,
      symbol: r'R$',
    ),
    CurrencyOption(
      code: 'USD',
      label: r'USD ($)'.hardcoded,
      description: 'Dólar americano'.hardcoded,
      symbol: r'$',
    ),
    CurrencyOption(
      code: 'EUR',
      label: 'EUR (€)'.hardcoded,
      description: 'Euro'.hardcoded,
      symbol: '€',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<SessionCubit, bool>(
      (cubit) => cubit.state.user.isAdmin,
    );
    final isUpdating = context.select<CompanyCubit, bool>(
      (cubit) => cubit.state.section(CompanySections.updateCurrency).isRunning,
    );

    final currentCurrency = parameters.currency.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(top: Sizes.p16),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const PlatformIcon(
                  materialIcon: Icons.payments_outlined,
                  cupertinoIcon: CupertinoIcons.money_dollar_circle,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BaseText.titleMedium('Moeda padrão'.hardcoded),
                      gapH4,
                      BaseText.bodySmall(
                        'Define a moeda padrão utilizada em ordens de serviço e planos de manutenção.'
                            .hardcoded,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                if (isUpdating) LoadingCircle.small(),
              ],
            ),
            gapH16,
            const Divider(height: 1),
            gapH12,
            ...supportedCurrencies.map((currency) {
              final isSelected = currentCurrency == currency.code;
              return InkWell(
                key: ValueKey('CurrencyOption_${currency.code}'),
                onTap: (!isAdmin || isUpdating || isSelected)
                    ? null
                    : () => context.read<CompanyCubit>().updateCurrency(
                        currency.code,
                      ),
                borderRadius: BorderRadius.circular(Sizes.p8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Sizes.p8,
                    horizontal: Sizes.p8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Sizes.p8),
                    color: isSelected
                        ? context.colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          )
                        : Colors.transparent,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                )
                              : context.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(Sizes.p8),
                        ),
                        child: BaseText.title(
                          currency.symbol,
                          color: isSelected
                              ? context.colorScheme.primary
                              : context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      gapW12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BaseText.bodyMedium(
                              currency.label,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? context.colorScheme.primary
                                  : context.colorScheme.onSurface,
                            ),
                            gapH4,
                            BaseText.bodySmall(
                              currency.description,
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: Sizes.p4),
                        child: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? context.colorScheme.primary
                              : context.colorScheme.outline,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
