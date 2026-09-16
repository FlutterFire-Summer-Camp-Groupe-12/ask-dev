import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/features/auth/domain/entities/auth_user.dart';

abstract class AuthGateway {
  Stream<AuthStatus> get statusStream;

  AuthStatus get status;

  /// Identifiant de l'utilisateur connecté, ou `null` s'il n'y en a pas.
  ///
  /// Permet aux autres features de rattacher une donnée à son auteur sans
  /// dépendre de la feature `auth`.
  String? get currentUserId;

  /// Utilisateur connecté, ou `null`. Expose pseudo/photo pour dénormaliser
  /// les informations d'auteur sur les questions et réponses.
  AuthUser? get currentUser;
}
