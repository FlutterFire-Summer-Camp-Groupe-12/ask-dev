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
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.signInWithEmail(
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
          context.router.replace(const HomeRoute());
        } else {
          context.showError(state.error!);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Connexion')),
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
                                : const Text('Se connecter'),
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
                                : () => context.router.push(const RegisterRoute()),
                            child: const Text("Pas encore de compte ? Inscrivez-vous"),
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