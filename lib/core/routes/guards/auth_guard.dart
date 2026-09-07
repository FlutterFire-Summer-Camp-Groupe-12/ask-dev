// import 'package:auto_route/auto_route.dart';

// import '../../session/auth_gateway.dart';

// /// Garde de navigation (auto_route) pour les écrans réservés aux
// /// utilisateurs connectés.
// ///
// /// S'appuie uniquement sur [AuthGateway] pour connaître l'état de
// /// connexion — elle ne connaît rien de la façon dont l'authentification
// /// est réellement implémentée par le reste de l'équipe.
// ///
// /// ⚠️ Le chemin de l'écran de connexion ([loginPath]) est passé en
// /// paramètre plutôt que référencé via une classe de route générée
// /// (ex: `LoginRoute()`), car `app_router.dart` ne déclare encore
// /// aucune route (`routes => const []`). Dès que l'équipe ajoute la
// /// route de connexion, on pourra remplacer
// /// `router.root.pushNamed(loginPath)` par `router.root.push(LoginRoute())`
// /// si on préfère la version typée.
// class AuthGuard extends AutoRouteGuard {
//   final AuthGateway authGateway;
//   final String loginPath;

//   AuthGuard(this.authGateway, {this.loginPath = '/login'});

//   @override
//   void onNavigation(NavigationResolver resolver, StackRouter router) {
//     final status = authGateway.status;

//     if (status.isAuthenticated) {
//       resolver.next(true);
//       return;
//     }

//     resolver.next(false);
//     router.root.pushNamed(loginPath);
//   }
// }
