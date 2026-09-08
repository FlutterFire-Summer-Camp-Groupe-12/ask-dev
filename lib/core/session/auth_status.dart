/// État de connexion de l'utilisateur, à un instant donné.
enum AuthStatus {
  /// L'état n'est pas encore connu (ex: au tout début du démarrage,
  /// avant d'avoir vérifié si une session est déjà persistée).
  unknown,

  /// L'utilisateur n'est pas connecté.
  unauthenticated,

  /// L'utilisateur est connecté.
  authenticated;

  /// Raccourci pratique pour éviter `status == AuthStatus.authenticated`
  /// un peu partout dans le code appelant.
  bool get isAuthenticated => this == AuthStatus.authenticated;
}