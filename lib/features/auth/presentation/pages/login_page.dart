import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/auth/presentation/manager/auth_state.dart';
import 'package:askdev/features/auth/presentation/widgets/auth_controls.dart';
import 'package:askdev/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.signIn(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        final becameAuthenticated =
            current.status == AuthStatus.authenticated &&
            previous.status != AuthStatus.authenticated;
        final failed = current.error != null && previous.error != current.error;
        return becameAuthenticated || failed;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.router.replace(const AppNavigationShellRoute());
        } else {
          context.showError(state.error!);
        }
      },
      child: AuthScaffold(
        title: 'Bon retour',
        subtitle: 'Connectez-vous pour poser vos questions et répondre.',
        form: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final busy = state.isSubmitting;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IdentifierField(
                    controller: _identifierController,
                    enabled: !busy,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PasswordField(
                    controller: _passwordController,
                    enabled: !busy,
                    onSubmitted: () => _submit(cubit),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: busy ? null : () => _submit(cubit),
                    child: busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Se connecter'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AuthDivider(),
                  const SizedBox(height: AppSpacing.lg),
                  GoogleSignInButton(
                    onPressed: cubit.signInWithGoogle,
                    enabled: !busy,
                  ),
                ],
              );
            },
          ),
        ),
        footer: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => TextButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.router.replace(const RegisterRoute()),
            child: const Text('Pas encore de compte ? Inscrivez-vous'),
          ),
        ),
      ),
    );
  }
}
