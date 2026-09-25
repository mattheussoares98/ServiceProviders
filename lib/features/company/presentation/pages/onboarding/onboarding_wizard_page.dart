import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/onboarding/onboarding_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/onboarding/widgets/company_info_step.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/onboarding/widgets/confirmation_step.dart';
import 'package:o_jogo_da_obra/features/company/presentation/pages/onboarding/widgets/work_type_step.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';

@RoutePage()
class OnboardingWizardPage extends HookWidget {
  const OnboardingWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController();

    return BlocProvider<OnboardingCubit>(
      create: (_) => GetIt.I<OnboardingCubit>(),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listenWhen: (previous, current) =>
            previous.currentStep != current.currentStep,
        listener: (context, state) {
          if (pageController.hasClients &&
              pageController.page?.round() != state.currentStep) {
            pageController.animateToPage(
              state.currentStep,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<OnboardingCubit>();
          final isLoading = state.section(BaseSections.load).isRunning;

          return BaseScaffold(
            isScrollable: false,
            appBar: BaseAppBar(
              title: 'Bem-vindo ao ServicePro'.hardcoded,
              showLeading: false,
            ),
            body: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  child: CompanyInfoStep(
                    cubit: cubit,
                    initialName: state.companyName,
                    initialCnpj: state.cnpj,
                  ),
                ),
                SingleChildScrollView(
                  child: WorkTypeStep(
                    cubit: cubit,
                    selectedWorkType: state.workType,
                  ),
                ),
                SingleChildScrollView(
                  child: ConfirmationStep(
                    cubit: cubit,
                    companyName: state.companyName,
                    cnpj: state.cnpj,
                    workType: state.workType,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
