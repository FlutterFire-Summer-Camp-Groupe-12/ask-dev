import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/themes/app_theme.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = sl<AppRouter>();
    return MaterialApp.router(
      title: 'askdev',
      debugShowCheckedModeBanner: false,
      theme: const AppTheme().light,
      routerConfig: appRouter.config(),
    );
  }
}