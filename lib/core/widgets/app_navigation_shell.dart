import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/widgets/brand_wordmark.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/auth/presentation/manager/auth_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Coquille de l'espace connecté : barre de navigation en bas sur téléphone,
/// rail latéral à partir de [AppLayout.railBreakpoint].
@RoutePage()
class AppNavigationShellPage extends StatelessWidget {
  const AppNavigationShellPage({super.key});

  static const int homeTab = 0;
  static const int profileTab = 1;
  static const int settingsTab = 2;

  static const _routes = [
    QuestionsHomeRoute(),
    ProfileRoute(),
    SettingsRoute(),
  ];

  static const _destinations = [
    (Icons.forum_outlined, Icons.forum_rounded, 'Accueil'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
    (Icons.settings_outlined, Icons.settings_rounded, 'Réglages'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        final signedOut =
            current.status == AuthStatus.unauthenticated &&
            previous.status != AuthStatus.unauthenticated;
        final failed = current.error != null && previous.error != current.error;
        return signedOut || failed;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.router.replace(const WelcomeRoute());
        } else {
          context.showError(state.error!);
        }
      },
      child: AutoTabsRouter(
        routes: _routes,
        transitionBuilder: (context, child, animation) =>
            FadeTransition(opacity: animation, child: child),
        builder: (context, child) {
          final tabs = AutoTabsRouter.of(context);
          void select(int index) {
            if (index != tabs.activeIndex) HapticFeedback.selectionClick();
            tabs.setActiveIndex(index);
          }

          final useRail =
              MediaQuery.sizeOf(context).width >= AppLayout.railBreakpoint;
          if (useRail) {
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: tabs.activeIndex,
                    onDestinationSelected: select,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: BrandWordmark(height: 36),
                    ),
                    destinations: [
                      for (final (icon, selected, label) in _destinations)
                        NavigationRailDestination(
                          icon: Icon(icon),
                          selectedIcon: Icon(selected),
                          label: Text(label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: child),
                ],
              ),
            );
          }

          return Scaffold(
            body: child,
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: context.colors.outlineVariant),
                ),
              ),
              child: NavigationBar(
                selectedIndex: tabs.activeIndex,
                onDestinationSelected: select,
                destinations: [
                  for (final (icon, selected, label) in _destinations)
                    NavigationDestination(
                      icon: Icon(icon),
                      selectedIcon: Icon(selected),
                      label: label,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
