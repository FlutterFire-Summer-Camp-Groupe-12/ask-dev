import 'package:flutter/material.dart';

/// Palette sombre partagée par les écrans de l'application.
///
/// Les écrans existants utilisent déjà ces valeurs en dur ; les nouveaux
/// écrans passent par cette classe pour garder une seule source de vérité.
abstract final class AppColors {
  /// Fond général des écrans.
  static const Color background = Color(0xFF0D0D0F);

  /// Fond des cartes et des champs de formulaire.
  static const Color surface = Color(0xFF111215);

  /// Fond des éléments posés sur une carte (chips, barre d'outils).
  static const Color surfaceHigh = Color(0xFF17181B);

  /// Bordure discrète (équivalent de `Colors.white12`).
  static const Color border = Color(0x1FFFFFFF);

  /// Bordure d'un élément survolé ou sélectionné (`Colors.white24`).
  static const Color borderStrong = Color(0x3DFFFFFF);

  /// Couleur d'accent : champ actif, bouton principal, lien.
  static const Color accent = Color(0xFF4F8DFD);

  /// Couleur des erreurs et des astérisques « champ requis ».
  static const Color danger = Color(0xFFE5534B);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0x8AFFFFFF);
  static const Color textFaint = Color(0x61FFFFFF);
}
