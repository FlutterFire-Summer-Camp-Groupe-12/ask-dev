import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/auth/presentation/manager/auth_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.authenticated &&
          previous.status != AuthStatus.authenticated,
      listener: (context, state) => context.router.replace(const AppNavigationShellRoute()),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                const _WelcomeLogo(),
                const Spacer(flex: 2),
                _WelcomeActions(context),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeLogo extends StatelessWidget {
  const _WelcomeLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/askdev_logo.png',
      width: 180,
      height: 180,
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions(this.context);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () => context.router.push(const LoginRoute()),
          child: const Text('Connexion'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.router.push(const RegisterRoute()),
          child: const Text('Inscription'),
        ),
      ],
    );
  }
}
