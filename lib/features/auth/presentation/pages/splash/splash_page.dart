import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/splash/splash_cubit.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = GetIt.I<SplashCubit>();
        Future.delayed(const Duration(seconds: 1), cubit.checkInitialRoute);
        return cubit;
      },
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          switch (state.target) {
            case SplashRouteTarget.acceptInvite:
              context.router.replace(const AcceptInviteRoute());
            case SplashRouteTarget.providerHome:
              context.router.replace(const ProviderHomeRoute());
            case SplashRouteTarget.home:
              context.router.replace(const HomeRoute());
            case SplashRouteTarget.login:
              context.router.replace(const LoginRoute());
            case SplashRouteTarget.initial:
              break;
          }
        },
        child: const BaseScaffold(body: Center(child: LoadingCircle())),
      ),
    );
  }
}
