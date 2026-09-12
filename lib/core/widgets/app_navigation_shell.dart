import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/widgets/app_bottom_navigation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AppNavigationShellPage extends StatelessWidget {
  const AppNavigationShellPage({super.key});

  static const _routes = [
    HomeRoute(),
    SearchRoute(),
    ProfileRoute(),
  ];

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
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
    );
  }
}