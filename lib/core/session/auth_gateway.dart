import 'package:askdev/core/session/auth_status.dart';

abstract class AuthGateway {
  Stream<AuthStatus> get statusStream;

  AuthStatus get status;
}