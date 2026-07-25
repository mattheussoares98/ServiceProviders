import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_state.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class ObservationsSection extends HookWidget {
  const ObservationsSection({
    required this.workOrderId,
    required this.companyId,
    super.key,
  });

  final String workOrderId;
  final String companyId;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () =>
          GetIt.I<WorkOrderObservationsCubit>()..fetchObservations(workOrderId),
    );

    final textController = useTextEditingController();

    final currentUser = context.select((SessionCubit c) => c.state.user);

    return BlocProvider.value(
      value: cubit,
      child: SliverMainAxisGroup(
        slivers: [
          BaseStateView<
            WorkOrderObservationsCubit,
            WorkOrderObservationsState,
            List<WorkOrderObservationEntity>
          >(
            isSliver: true,
            dataSelector: (state) => state.observations,
            onRetry: () => cubit.fetchObservations(workOrderId),
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

              return SliverList.builder(
                itemCount: observations.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return BaseText.title('Observações'.hardcoded);
                  }

                  final item = observations[index - 1];
                  final isAuthor = currentUser.id == item.authorId;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Sizes.p8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BaseText(
                                item.authorName,
                                fontWeight: FontWeight.bold,
                              ),
                              Row(
                                children: [
                                  BaseText(
                                    item.createdAt.formatDate(
                                      DateFormatType.ddMMyyyyHHmm,
                                    ),
                                  ),
                                  if (isAuthor) ...[
                                    gapW8,
                                    GestureDetector(
                                      onTap: () async {
                                        await cubit.deleteObservation(item.id);
                                      },
                                      child: const PlatformIcon(
                                        materialIcon: Icons.delete_outline,
                                        cupertinoIcon: CupertinoIcons.trash,
                                        size: Sizes.p16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
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
          //TODO check to change where show this ontion because it is being showed inside the details page, not editing. Also, add a scroll to the top floating action button when has scrolled a lot to the bottom
          gapSliverH16,
          SliverToBoxAdapter(
            child: BaseTextFormField(
              controller: textController,
              hintText: 'Adicionar uma observação...'.hardcoded,
              maxLines: 8,
              maxLength: 2000,
            ),
          ),
          gapSliverH8,
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  BlocSelector<
                    WorkOrderObservationsCubit,
                    WorkOrderObservationsState,
                    bool
                  >(
                    selector: (state) => state.status == StateStatus.saving,
                    builder: (context, isSubmitting) {
                      return PrimaryButton(
                        text: 'Enviar'.hardcoded,
                        isLoading: isSubmitting,
                        onTap: () async {
                          final content = textController.text.trim();
                          if (content.isEmpty) return;

                          final success = await cubit.createObservation(
                            companyId: companyId,
                            workOrderId: workOrderId,
                            authorId: currentUser.id,
                            authorName: currentUser.name,
                            content: content,
                          );

                          if (success) {
                            textController.clear();
                          }
                        },
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
