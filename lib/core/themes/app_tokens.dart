import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Échelle d'espacement : tous les écarts de l'app en sont des multiples.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Rayons d'angle. `md` pour les contrôles (champs, boutons), `lg` pour les
/// cartes, `xl` pour les feuilles et dialogues.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}

/// Largeurs de mise en page partagées par tous les écrans.
abstract final class AppLayout {
  /// Colonne de lecture : fil, détail, profil, formulaire de question.
  static const double contentMaxWidth = 720;

  /// Formulaires courts : connexion, inscription, édition du profil.
  static const double formMaxWidth = 460;

  /// Au-delà, la barre de navigation du bas devient un rail latéral.
  static const double railBreakpoint = 840;

  /// Marge latérale minimale sur téléphone.
  static const double gutter = AppSpacing.lg;

  /// Marges d'une liste pleine largeur dont le contenu reste centré dans
  /// [maxWidth]. La liste défile sur toute la largeur (barre de défilement au
  /// bord de l'écran) mais les éléments ne dépassent jamais la colonne.
  static EdgeInsets listPadding(
    BuildContext context, {
    double maxWidth = contentMaxWidth,
    double top = AppSpacing.lg,
    double bottom = AppSpacing.xxl,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final side = math.max(gutter, (width - maxWidth) / 2);
    return EdgeInsets.fromLTRB(side, top, side, bottom);
  }
}
