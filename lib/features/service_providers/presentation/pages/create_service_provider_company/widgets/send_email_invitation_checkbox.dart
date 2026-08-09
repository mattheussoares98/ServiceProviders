part of '../create_update_service_provider_company_page.dart';

class _SendEmailInvitationCheckbox extends StatelessWidget {
  const _SendEmailInvitationCheckbox({
    required this.emailController,
    required this.sendInvite,
  });
  final TextEditingController emailController;
  final ValueNotifier<bool> sendInvite;

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
                value: isValid && sendInvite.value,
                title: 'Enviar convite de acesso por e-mail'.hardcoded,
                onChanged: isValid
                    ? (val) => sendInvite.value = val ?? false
                    : null,
              ),
            ),
            gapW4,
            Tooltip(
              triggerMode: .tap,
              showDuration: const Duration(seconds: 3),
              message:
                  'Essa opção deve ser utilizada quando você quiser permitir que o prestador de serviço consiga acessar o aplicativo e fazer alterações nas ordens de serviço em que ele seja o responsável'
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
