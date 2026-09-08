import 'auth_status.dart';

/// Interface unique donnant accès à l'état de connexion courant de
/// l'application, et permettant de réagir à ses changements.
///
/// Toute la logique d'authentification concrète (Firebase Auth) reste
/// dans la feature `auth/` — `AuthGateway` n'expose que ce dont le
/// reste de l'application (navigation, gardes d'accès) a besoin de
/// savoir : "est-on connecté, et est-ce que ça change ?".
abstract class AuthGateway {
  /// État de connexion courant, lu de façon synchrone.
  AuthStatus get status;

  /// Flux notifiant chaque changement d'état de connexion (connexion,
  /// déconnexion, expiration de session...).
  Stream<AuthStatus> get authChanges;

  /// Déconnecte l'utilisateur courant.
  Future<void> signOut();

  /// Force une nouvelle vérification de l'état de connexion — par
  /// exemple au lancement de l'application, pour relire la session
  /// éventuellement persistée avant d'afficher le premier écran.
  Future<void> refresh();
}