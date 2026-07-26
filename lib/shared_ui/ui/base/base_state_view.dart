import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class BaseStateView<C extends BaseCubit<S>, S extends BaseState, D>
    extends StatelessWidget {
  const BaseStateView({
    super.key,
    required this.dataSelector,
    required this.builder,
    this.onRetry,
    this.isSliver = false,
  });

  final D Function(S state) dataSelector;
  final Widget Function(BuildContext context, D data) builder;
  final VoidCallback? onRetry;
  final bool isSliver;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, S>(
      //!It automatically searches for the nearest Cubit with type C
      builder: (context, state) {
        if (state.status == StateStatus.loading) {
          return isSliver
              ? const SliverToBoxAdapter(child: LoadingCircle())
              : const LoadingCircle();
        }

        if (state.status == StateStatus.loadingError) {
          final Widget errorWidget = Center(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.p16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BaseText(
                    state.errorMessage ??
                        'Ocorreu um erro não esperado. Tente novamente'
                            .hardcoded,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                  if (onRetry != null) ...[
                    gapH16,
                    BaseButton(
                      color: Colors.red,
                      onTap: onRetry,
                      text: 'Tentar novamente'.hardcoded,
                    ),
                  ],
                ],
              ),
            ),
          );

          if (isSliver) {
            return SliverToBoxAdapter(child: errorWidget);
          }

          return errorWidget;
        }

        return builder(context, dataSelector(state));
      },
    );
  }
}
