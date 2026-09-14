import 'package:flutter/material.dart';

/// Thèmes clair/sombre de l'application.
///
/// Direction visuelle « Claude AI » : fond crème chaud, cartes quasi
/// identiques au fond différenciées par une bordure fine, coins généreux,
/// hiérarchie typographique claire, une seule couleur d'accent (bleu marine
/// hérité de [Colors.blueAccent]). Le rouge est réservé aux actions
/// destructrices, rendues comme boutons.
///
/// Tous les écrans partagent cette signature : aucune page ne doit définir
/// ses propres couleurs ou tailles hors des tokens du [ColorScheme].
class AppTheme {
  const AppTheme();

  ThemeData get light => _build(_warmScheme(Brightness.light));

  ThemeData get dark => _build(_warmScheme(Brightness.dark));

  /// Palette chaude déclinée en clair/sombre. Les valeurs issues du seed
  /// (accent bleu marine, erreur) sont conservées ; seuls les neutres et le
  /// fond sont remplacés par des gris chauds.
  static ColorScheme _warmScheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: brightness,
    );
    if (brightness == Brightness.dark) {
      return base.copyWith(
        surface: const Color(0xFF141311),
        surfaceContainerLow: const Color(0xFF181714),
        surfaceContainer: const Color(0xFF1D1C19),
        surfaceContainerHighest: const Color(0xFF24231F),
        surfaceContainerHigh: const Color(0xFF24231F),
        onSurface: const Color(0xFFECEAE4),
        onSurfaceVariant: const Color(0xFFA5A29A),
        outline: const Color(0xFF8E8B84),
        outlineVariant: const Color(0xFF3A3833),
      );
    }
    return base.copyWith(
      surface: const Color(0xFFFAF9F5),
      surfaceContainerLow: const Color(0xFFFAF9F5),
      surfaceContainer: const Color(0xFFF3F2ED),
      surfaceContainerHighest: const Color(0xFFF0EFEA),
      surfaceContainerHigh: const Color(0xFFF0EFEA),
      onSurface: const Color(0xFF1F1E1D),
      onSurfaceVariant: const Color(0xFF85847C),
      outline: const Color(0xFF1F1E1D).withValues(alpha: 0.48),
      outlineVariant: const Color(0xFF1F1E1D).withValues(alpha: 0.12),
    );
  }

  ThemeData _build(ColorScheme scheme) {
    final rounded12 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    // Coins : 16 sur les cartes, 12 sur les boutons/inputs/chips.
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: scheme.outlineVariant),
    );

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        actionsIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      // Cartes : fond quasi identique à l'écran, séparées par une bordure
      // fine plutôt que par un contraste de remplissage.
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: cardShape,
        clipBehavior: Clip.antiAlias,
      ),
      // Champs : fond chaud rempli, label flottant + placeholder, coins 12.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: scheme.outline, fontSize: 13),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        disabledBorder: fieldBorder,
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: rounded12,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: rounded12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: rounded12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 12),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        deleteIconColor: scheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}