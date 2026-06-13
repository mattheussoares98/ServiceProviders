import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(create: (context) => GetIt.I<HomeCubit>()),
        BlocProvider<CompanyCubit>(
          create: (context) => GetIt.I<CompanyCubit>()..loadCompany(),
        ),
      ],
      child: const AutoRouter(),
    );
  }
}
