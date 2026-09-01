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
    this.sectionKey,
  });

  final D Function(S state) dataSelector;
  final Widget Function(BuildContext context, D data) builder;
  final VoidCallback? onRetry;
  final bool isSliver;

  /// When provided, this view reacts only to [BaseState.sections]\[sectionKey]
  /// instead of the global [BaseState.status].
  ///
  /// This allows independent loading/error states for sub-sections of a page:
  /// an error in one section does not affect widgets using a different key or
  /// no key at all.
  final SectionKey? sectionKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, S>(
      builder: (context, state) {
        final sectionStatus = sectionKey != null
            ? state.sections[sectionKey!]
            : null;

        final isLoading = sectionStatus != null
            ? sectionStatus == SectionStatus.running
            : state.status == DataStatus.loading;

        if (isLoading) {
          return isSliver
              ? const SliverToBoxAdapter(child: LoadingCircle())
              : const LoadingCircle();
        }

        final hasError = sectionStatus != null
            ? sectionStatus == SectionStatus.error
            : state.status == DataStatus.loadingError;

        if (hasError) {
          // For section errors, the cubit always calls showErrorToast(message)
          // and also stores the last error in state.errorMessage as a fallback.
          final errorMessage = state.errorMessage?.isNotEmpty == true
              ? state.errorMessage!
              : 'Ocorreu um erro não esperado. Tente novamente'.hardcoded;

          final Widget errorWidget = Center(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.p16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BaseText(
                    errorMessage,
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
