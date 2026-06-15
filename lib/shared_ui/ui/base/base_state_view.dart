import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseStateView<C extends BaseCubit<S>, S extends BaseState, D>
    extends StatelessWidget {
  const BaseStateView({
    super.key,
    required this.dataSelector,
    required this.builder,
    this.onRetry,
  });

  final D Function(S state) dataSelector;
  final Widget Function(BuildContext context, D data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, S>(
      //!It automatically searches for the nearest Cubit with type C
      builder: (context, state) {
        if (state.status == StateStatus.loading) {
          return const LoadingCircle();
        }

        if (state.errorMessage?.isNotEmpty == true) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.p16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BaseText(state.errorMessage!),
                  if (onRetry != null) ...[
                    gapH16,
                    PrimaryButton(
                      onTap: onRetry!,
                      text: 'Tentar novamente'.hardcoded,
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return builder(context, dataSelector(state));
      },
    );
  }
}
