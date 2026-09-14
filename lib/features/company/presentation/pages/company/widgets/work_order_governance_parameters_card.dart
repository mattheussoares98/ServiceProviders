import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_switch.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class WorkOrderGovernanceParametersCard extends HookWidget {
  const WorkOrderGovernanceParametersCard({
    super.key,
    required this.parameters,
  });

  final CompanyParameterEntity parameters;

  @override
  Widget build(BuildContext context) {
    final allowProviderCreate = useState(
      parameters.allowProviderCreateWorkOrder,
    );

    useEffect(() {
      allowProviderCreate.value = parameters.allowProviderCreateWorkOrder;
      return null;
    }, [parameters.allowProviderCreateWorkOrder]);

    final isAdmin = context.select<SessionCubit, bool>(
      (cubit) => cubit.state.user.isAdmin,
    );

    final isUpdating = context.select<CompanyCubit, bool>(
      (cubit) => cubit.state
          .section(CompanySections.updateGovernanceParameters)
          .isRunning,
    );

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
                  materialIcon: Icons.assignment_turned_in_outlined,
                  cupertinoIcon: Icons.assignment_turned_in_outlined,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BaseText.titleMedium(
                        'Governança de ordens de serviço'.hardcoded,
                      ),
                      gapH4,
                      BaseText.bodySmall(
                        'Defina regras de permissão e abertura de ordens de serviço para prestadores de serviço.'
                            .hardcoded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gapH16,
            const Divider(height: 1),
            gapH16,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BaseText.bodyLarge(
                        'Permitir prestadores criarem ordens de serviço'
                            .hardcoded,
                        fontWeight: FontWeight.w600,
                      ),
                      gapH4,
                      BaseText.bodySmall(
                        'Quando desativado, apenas usuários internos podem abrir ordens de serviço.'
                            .hardcoded,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                gapW12,
                if (isUpdating)
                  const Padding(
                    padding: EdgeInsets.all(Sizes.p8),
                    child: LoadingCircle(),
                  )
                else
                  BaseSwitch(
                    value: allowProviderCreate.value,
                    onChanged: isAdmin
                        ? (value) async {
                            final previousValue = allowProviderCreate.value;
                            allowProviderCreate.value = value;
                            final success = await context
                                .read<CompanyCubit>()
                                .updateAllowProviderCreateWorkOrder(value);
                            if (!success && context.mounted) {
                              allowProviderCreate.value = previousValue;
                            }
                          }
                        : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
