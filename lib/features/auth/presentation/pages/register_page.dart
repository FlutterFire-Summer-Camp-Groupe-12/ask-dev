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
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _pseudoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.signUp(
      pseudo: _pseudoController.text.trim(),
      email: _emailController.text.trim(),
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
        title: 'Créer un compte',
        subtitle: 'Rejoignez la communauté, c\'est gratuit.',
        form: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final busy = state.isSubmitting;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PseudoField(controller: _pseudoController, enabled: !busy),
                  const SizedBox(height: AppSpacing.lg),
                  EmailField(controller: _emailController, enabled: !busy),
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
                        : const Text('Créer le compte'),
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
                : () => context.router.replace(const LoginRoute()),
            child: const Text('Déjà un compte ? Connectez-vous'),
          ),
        ),
      ),
    );
  }
}
