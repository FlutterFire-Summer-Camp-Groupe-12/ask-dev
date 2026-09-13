import 'package:askdev/core/routes/guards/auth_guard.dart';
import 'package:askdev/core/widgets/app_navigation_shell.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/auth/presentation/pages/login_page.dart';
import 'package:askdev/features/auth/presentation/pages/register_page.dart';
import 'package:askdev/features/auth/presentation/pages/welcome_page.dart';
import 'package:askdev/features/forum/presentation/pages/ask_question_page.dart';
import 'package:askdev/features/forum/presentation/pages/questions_home_page.dart';
import 'package:askdev/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:askdev/features/profile/presentation/pages/profile_page.dart';
import 'package:askdev/features/settings/presentation/pages/settings_page.dart';
import 'package:auto_route/auto_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/', initial: true, page: WelcomeRoute.page),
        AutoRoute(path: '/login', page: LoginRoute.page),
        AutoRoute(path: '/register', page: RegisterRoute.page),
        AutoRoute(path: '/edit-profile', page: EditProfileRoute.page),
        AutoRoute(
          path: '/profile',
          page: ProfileRoute.page,
          guards: [sl<AuthGuard>()],
        ),
        AutoRoute(
          path: '/home',
          page: AppNavigationShellRoute.page,
          guards: [sl<AuthGuard>()],
          children: [
            AutoRoute(path: 'accueil', page: QuestionsHomeRoute.page, initial: true),
            AutoRoute(path: 'publier', page: AskQuestionRoute.page),
            AutoRoute(path: 'reglages', page: SettingsRoute.page),
          ],
        ),
      ];
}