part of '../create_update_service_provider_company_page.dart';

class _SendEmailInvitationCheckbox extends StatelessWidget {
  const _SendEmailInvitationCheckbox({
    required this.emailController,
    required this.sendInvite,
    this.isInviteAccepted = false,
  });
  final TextEditingController emailController;
  final ValueNotifier<bool> sendInvite;
  final bool isInviteAccepted;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: emailController,
      builder: (context, value, child) {
        final isValid = EmailValidator().isValid(value.text.trim());
        return Row(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: BaseCheckbox(
                value: isInviteAccepted || (isValid && sendInvite.value),
                title: 'Enviar convite de acesso por e-mail'.hardcoded,
                onChanged: isInviteAccepted
                    ? null
                    : (isValid
                          ? (val) => sendInvite.value = val ?? false
                          : null),
              ),
            ),
            gapW4,
            Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 3),
              message: isInviteAccepted
                  ? 'Convite já aceito pelo prestador de serviço'.hardcoded
                  : 'Essa opção deve ser utilizada quando você quiser permitir que o prestador de serviço consiga acessar o aplicativo e fazer alterações nas ordens de serviço em que ele seja o responsável'
                        .hardcoded,
              child: const PlatformIcon(
                materialIcon: Icons.info,
                cupertinoIcon: CupertinoIcons.info,
              ),
            ),
          ],
        );
      },
    );
  }
}
