import 'package:flutter/material.dart';

/// Couleurs de la marque, mesurées sur le logo.
abstract final class BrandColors {
  /// Bleu azur de « ASK ».
  static const Color azure = Color(0xFF0182F3);

  /// Gris ardoise de « DEV ».
  static const Color slate = Color(0xFF5A5D66);

  /// Fond ardoise profond de l'icône d'application.
  static const Color ink = Color(0xFF0F172A);
}

/// Couleurs sémantiques absentes du [ColorScheme] Material.
///
/// Lire via `context.palette` : chaque valeur a sa déclinaison claire et
/// sombre, contrastes vérifiés au niveau AA.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.tagBackground,
    required this.tagForeground,
    required this.codeBackground,
    required this.skeleton,
  });

  /// Question ayant reçu des réponses, action réussie.
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color tagBackground;
  final Color tagForeground;

  /// Fond des blocs de code et du code en ligne.
  final Color codeBackground;

  /// Couleur de base des squelettes de chargement.
  final Color skeleton;

  static const AppPalette light = AppPalette(
    success: Color(0xFF067647),
    successContainer: Color(0xFFDCFAE6),
    onSuccessContainer: Color(0xFF05603A),
    tagBackground: Color(0xFFE6F1FE),
    tagForeground: Color(0xFF0A5BB5),
    codeBackground: Color(0xFFF1F4F9),
    skeleton: Color(0xFFE4E9F0),
  );

  static const AppPalette dark = AppPalette(
    success: Color(0xFF47CD89),
    successContainer: Color(0xFF0B3B25),
    onSuccessContainer: Color(0xFFB7F5CF),
    tagBackground: Color(0xFF12305A),
    tagForeground: Color(0xFFA9D2FF),
    codeBackground: Color(0xFF0D1526),
    skeleton: Color(0xFF1B2640),
  );

  @override
  AppPalette copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? tagBackground,
    Color? tagForeground,
    Color? codeBackground,
    Color? skeleton,
  }) {
    return AppPalette(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      tagBackground: tagBackground ?? this.tagBackground,
      tagForeground: tagForeground ?? this.tagForeground,
      codeBackground: codeBackground ?? this.codeBackground,
      skeleton: skeleton ?? this.skeleton,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      tagBackground: Color.lerp(tagBackground, other.tagBackground, t)!,
      tagForeground: Color.lerp(tagForeground, other.tagForeground, t)!,
      codeBackground: Color.lerp(codeBackground, other.codeBackground, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
