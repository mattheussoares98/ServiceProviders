import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_state.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class ObservationsSection extends HookWidget {
  const ObservationsSection({required this.workOrder, super.key});

  final WorkOrderEntity workOrder;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkOrderObservationsCubit>();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final textController = useTextEditingController();

    Future<void> onSubmit() async {
      if (formKey.currentState?.validate() != true) return;

      final content = textController.text.trim();
      if (content.isEmpty) return;

      final success = await cubit.createObservation(
        workOrder: workOrder,
        content: content,
      );

      if (success) {
        textController.clear();
      }
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: BaseText.title('Observações'.hardcoded)),
        BaseStateView<
          WorkOrderObservationsCubit,
          WorkOrderObservationsState,
          List<WorkOrderObservationEntity>
        >(
          isSliver: true,
          dataSelector: (state) => state.observations,
          onRetry: () => cubit.fetchObservations(workOrder.id),
          builder: (context, observations) {
            if (observations.isEmpty) {
              return SliverToBoxAdapter(
                child: BaseText(
                  'Nenhuma observação registrada'.hardcoded,
                  fontStyle: FontStyle.italic,
                  color: context.theme.disabledColor,
                ),
              );
            }

            return ResponsiveListFlow(
              maxItemWidth: ScreenType.phone.maxWidth,
              itemCount: observations.length,
              isSliver: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = observations[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Sizes.p8),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: BaseText(
                                item.authorName,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            BlocSelector<
                              WorkOrderObservationsCubit,
                              WorkOrderObservationsState,
                              bool
                            >(
                              selector: (state) =>
                                  state.sections[WorkOrderObservationsSection
                                      .deleteObservation] ==
                                  StateStatus.deleting,
                              builder: (context, isDeleting) {
                                return BaseIconButton(
                                  isLoading: isDeleting,
                                  onPressed: () {
                                    showAlertDialog(
                                      context: context,
                                      title: 'Excluir observação'.hardcoded,
                                      contentText:
                                          'Deseja realmente excluir a observação?'
                                              .hardcoded,
                                      cancelActionText: 'Não'.hardcoded,
                                      defaultActionText: 'Sim'.hardcoded,
                                      onOkPressed: () =>
                                          cubit.deleteObservation(item.id),
                                    );
                                  },
                                  permission:
                                      const ActionPermission.workOrderSubAction(
                                        WorkOrderSubAction.deleteObservation,
                                      ),
                                  platformIcon: const PlatformIcon(
                                    materialIcon: Icons.delete_outline,
                                    cupertinoIcon: CupertinoIcons.trash,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        BaseText(
                          item.createdAt.formatDate(
                            DateFormatType.ddMMyyyyHHmm,
                          ),
                        ),
                        gapH8,
                        BaseText(item.content),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        gapSliverH16,
        if (!workOrder.status.isOpen &&
            !workOrder.status.isCompleted &&
            !workOrder.status.isPendingConclusionApproval)
          SliverToBoxAdapter(
            child: Form(
              key: formKey,
              child:
                  BlocSelector<
                    WorkOrderObservationsCubit,
                    WorkOrderObservationsState,
                    bool
                  >(
                    selector: (state) => state.status == StateStatus.saving,
                    builder: (context, isSubmitting) {
                      return Column(
                        children: [
                          BaseTextFormField(
                            controller: textController,
                            hintText: 'Adicionar uma observação...'.hardcoded,
                            maxLines: 8,
                            maxLength: 2000,
                            enabled: !isSubmitting,
                            autovalidateMode:
                                AutovalidateMode.onUserInteractionIfError,
                            validator: FormValidators.compose([
                              NonEmptyValidator(),
                              MinLengthValidator(10),
                            ]),
                          ),
                          gapH8,
                          BaseButton(
                            text: 'Adicionar observação'.hardcoded,
                            isLoading: isSubmitting,
                            onTap: onSubmit,
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ),
      ],
    );
  }
}
