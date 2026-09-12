import 'package:askdev/core/session/auth_status.dart';

abstract class AuthGateway {
  Stream<AuthStatus> get statusStream;

  AuthStatus get status;

  /// Identifiant de l'utilisateur connecté, ou `null` s'il n'y en a pas.
  ///
  /// Permet aux autres features de rattacher une donnée à son auteur sans
  /// dépendre de la feature `auth`.
  String? get currentUserId;
}
