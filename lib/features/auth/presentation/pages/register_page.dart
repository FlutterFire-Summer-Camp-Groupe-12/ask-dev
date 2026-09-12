import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/auth/presentation/manager/auth_state.dart';
import 'package:askdev/features/auth/presentation/widgets/auth_controls.dart';
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
        final becameAuthenticated = current.status == AuthStatus.authenticated &&
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
      child: Scaffold(
        appBar: AppBar(title: const Text('Inscription')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PseudoField(controller: _pseudoController, enabled: !state.isSubmitting),
                          const SizedBox(height: 16),
                          EmailField(controller: _emailController, enabled: !state.isSubmitting),
                          const SizedBox(height: 16),
                          PasswordField(
                            controller: _passwordController,
                            enabled: !state.isSubmitting,
                            onSubmitted: () => _submit(cubit),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: state.isSubmitting ? null : () => _submit(cubit),
                            child: state.isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Créer le compte'),
                          ),
                          const SizedBox(height: 12),
                          GoogleSignInButton(
                            onPressed: cubit.signInWithGoogle,
                            enabled: !state.isSubmitting,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: state.isSubmitting
                                ? null
                                : () => context.router.push(const LoginRoute()),
                            child: const Text('Déjà un compte ? Connectez-vous'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}