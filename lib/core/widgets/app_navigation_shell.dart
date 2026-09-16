import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/core/widgets/app_bottom_navigation.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/auth/presentation/manager/auth_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AppNavigationShellPage extends StatelessWidget {
  const AppNavigationShellPage({super.key});

  static const _routes = [
    QuestionsHomeRoute(),
    AskQuestionRoute(),
    SettingsRoute(),
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
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);
          return Scaffold(
            body: child,
            bottomNavigationBar: AppBottomNavigation(
              currentIndex: tabsRouter.activeIndex,
              onDestinationSelected: tabsRouter.setActiveIndex,
            ),
          );
        },
      ),
    );
  }
}
