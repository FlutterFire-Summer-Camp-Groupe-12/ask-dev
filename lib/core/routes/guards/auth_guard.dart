import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:auto_route/auto_route.dart';

class AuthGuard extends AutoRouteGuard {
  AuthGuard({required AuthGateway authGateway}) : _authGateway = authGateway;

  final AuthGateway _authGateway;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_authGateway.status == AuthStatus.authenticated) {
      resolver.next(true);
      return;
    }
    resolver.next(false);
    router.replace(const LoginRoute());
  }
}