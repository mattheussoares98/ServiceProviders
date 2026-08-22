import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_state.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';

class OfflineAdvisoryListener extends StatelessWidget {
  const OfflineAdvisoryListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OfflineAdvisoryCubit, OfflineAdvisoryState>(
      listenWhen: (previous, current) =>
          current.shouldShowDialog &&
          previous.advisoryEvent != current.advisoryEvent,
      listener: (context, state) {
        final event = state.advisoryEvent;
        if (event == null) return;

        final buffer = StringBuffer();
        if (event.hasBreachedDuration && event.hasBreachedRequests) {
          buffer.write(
            'Você está operando em modo offline há mais de ${event.offlineDuration.inHours} horas e possui ${event.pendingMutationCount} alterações pendentes de sincronização'
                .hardcoded,
          );
        } else if (event.hasBreachedDuration) {
          buffer.write(
            'Você está operando em modo offline há mais de ${event.offlineDuration.inHours} horas'
                .hardcoded,
          );
        } else {
          buffer.write(
            'Você possui ${event.pendingMutationCount} alterações pendentes salvas localmente no dispositivo'
                .hardcoded,
          );
        }
        buffer.write(
          '\n\nRecomendamos conectar-se à internet assim que possível para sincronizar seus dados com o servidor e evitar conflitos'
              .hardcoded,
        );

        showAlertDialog(
          context: context,
          title: 'Aviso de modo offline'.hardcoded,
          contentText: buffer.toString(),
          defaultActionText: 'Entendi'.hardcoded,
          onOkPressed: () {
            context.read<OfflineAdvisoryCubit>().dismissAlert();
          },
        );
      },
      child: child,
    );
  }
}
