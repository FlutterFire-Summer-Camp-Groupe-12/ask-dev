import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/widgets/brand_wordmark.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/auth/presentation/manager/auth_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const _highlights = [
    (Icons.help_outline_rounded, 'Posez vos questions de développement'),
    (Icons.code_rounded, 'Partagez du code coloré et lisible'),
    (Icons.bolt_rounded, 'Recevez des réponses de la communauté'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.authenticated &&
          previous.status != AuthStatus.authenticated,
      listener: (context, state) =>
          context.router.replace(const AppNavigationShellRoute()),
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primaryContainer.withValues(alpha: 0.55),
                colors.surface,
              ],
              stops: const [0, 0.55],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.formMaxWidth,
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    const Center(child: BrandWordmark(height: 96)),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Le forum des développeurs',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Une question, du code, une réponse. '
                      'Entre développeurs.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    for (final (icon, label) in _highlights)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(icon, size: 20, color: colors.primary),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                label,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                    FilledButton(
                      onPressed: () =>
                          context.router.push(const RegisterRoute()),
                      child: const Text('Créer un compte'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => context.router.push(const LoginRoute()),
                      child: const Text('J\'ai déjà un compte'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
