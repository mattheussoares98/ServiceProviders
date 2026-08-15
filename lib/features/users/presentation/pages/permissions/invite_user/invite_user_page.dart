import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/invite_user/invite_user_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/invite_user/widgets/email_field.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/invite_user/widgets/group_permission_dropdown.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/invite_user/widgets/invite_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class InviteUserPage extends HookWidget {
  const InviteUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    observeLoading([
      ObservedLoadingTarget(context.read<InviteUserCubit>()),
    ]);

    final selectedGroup = useState<PermissionGroupEntity?>(null);

    return BaseScaffold(
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BaseText.headline('Convidar usuário'.hardcoded),
                BaseText(
                  'Envie um convite por e-mail para vincular um novo colaborador à sua empresa.'
                      .hardcoded,
                ),
                gapH16,
                EmailField(emailController: emailController),
                gapH16,
                GroupPermissionDropdown(selectedGroup: selectedGroup),
              ],
            ),
            gapH12,
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancelar'.hardcoded,
                    onTap: Navigator.of(context).pop,
                  ),
                ),
                gapW12,
                Expanded(
                  child: InviteButton(
                    formKey: formKey,
                    emailController: emailController,
                    selectedGroup: selectedGroup,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
