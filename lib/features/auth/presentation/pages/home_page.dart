import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/auth/presentation/manager/auth_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        final signedOut = current.status == AuthStatus.unauthenticated &&
            previous.status != AuthStatus.unauthenticated;
        final failed = current.error != null && previous.error != current.error;
        return signedOut || failed;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.router.replace(const WelcomeRoute());
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Accueil')),
        body: Center(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state.user;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user?.displayName ?? user?.email ?? 'Connecté'),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.read<AuthCubit>().signOut(),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}