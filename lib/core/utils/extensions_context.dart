import 'package:flutter/material.dart';

/// Raccourcis sur [BuildContext] pour accéder au thème et afficher des
/// messages (SnackBar) depuis n'importe quel écran, sans répéter
/// `ScaffoldMessenger.of(context)` ni reconstruire la mise en forme.
extension BuildContextExtensions on BuildContext {
  /// Thème courant.
  ThemeData get theme => Theme.of(this);

  /// Palette de couleurs du thème courant.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Styles de texte du thème courant.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Taille de la fenêtre courante.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Le [ScaffoldMessengerState] le plus proche, ou `null` si l'écran n'est
  /// plus monté / n'a pas de `Scaffold` au-dessus de lui.
  ScaffoldMessengerState? get _messenger => ScaffoldMessenger.maybeOf(this);

  /// Affiche une SnackBar avec [message].
  ///
  /// La SnackBar en cours est masquée pour éviter les files d'attente quand
  /// plusieurs messages arrivent coup sur coup. Retourne `null` si aucun
  /// `ScaffoldMessenger` n'est disponible (écran démonté, par exemple).
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar(
    String message, {
    Color? background,
    Color? foreground,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = _messenger;
    if (messenger == null) return null;

    final scheme = colors;
    final textColor = foreground ?? scheme.onInverseSurface;

    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(message, style: TextStyle(color: textColor)),
            ),
          ],
        ),
        backgroundColor: background,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Affiche un message d'erreur aux couleurs d'erreur du thème.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showError(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    return showSnackBar(
      message,
      background: colors.error,
      foreground: colors.onError,
      icon: Icons.error_outline,
      duration: duration,
      action: action,
    );
  }

  /// Affiche un message de succès.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    return showSnackBar(
      message,
      background: colors.primary,
      foreground: colors.onPrimary,
      icon: Icons.check_circle_outline,
      duration: duration,
      action: action,
    );
  }

  /// Masque la SnackBar affichée, s'il y en a une.
  void hideSnackBar() => _messenger?.hideCurrentSnackBar();
}
