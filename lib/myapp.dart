import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/themes/app_theme.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = sl<AppRouter>();
    return BlocProvider<AuthCubit>(
      create: (context) => sl<AuthCubit>(),
      child: MaterialApp.router(
        title: 'askdev',
        debugShowCheckedModeBanner: false,
        theme: const AppTheme().light,
        routerConfig: appRouter.config(),
      ),
    );
  }
}