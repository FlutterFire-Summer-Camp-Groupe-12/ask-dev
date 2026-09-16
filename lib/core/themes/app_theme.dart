import 'package:askdev/core/themes/app_palette.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:flutter/material.dart';

/// Thèmes clair et sombre de l'application.
///
/// Direction visuelle alignée sur le logo : neutres froids tirant sur
/// l'ardoise, bleu azur comme unique accent, Inter pour le texte et
/// JetBrains Mono pour le code. Les écrans ne définissent ni couleur ni
/// taille de police : ils lisent le [ColorScheme], le [TextTheme], la
/// [AppPalette] et les jetons de `app_tokens.dart`.
///
/// Échelle typographique, six tailles : 26, 20, 16, 14, 13 et 12.
class AppTheme {
  const AppTheme();

  static const String fontFamily = 'Inter';
  static const String monoFamily = 'JetBrainsMono';

  ThemeData get light => _build(_lightScheme, AppPalette.light);

  ThemeData get dark => _build(_darkScheme, AppPalette.dark);

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0A6DD9),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD9EBFF),
    onPrimaryContainer: Color(0xFF003A73),
    secondary: BrandColors.slate,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE4E7EC),
    onSecondaryContainer: Color(0xFF1E2330),
    tertiary: Color(0xFF0E7C86),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC8291B),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE4E2),
    onErrorContainer: Color(0xFF7A271A),
    surface: Color(0xFFF5F7FA),
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF475569),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF0F3F8),
    surfaceContainerHigh: Color(0xFFE7ECF3),
    surfaceContainerHighest: Color(0xFFDEE5EE),
    outline: Color(0xFF5B6B80),
    outlineVariant: Color(0xFFE2E8F0),
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF1F5F9),
    inversePrimary: Color(0xFF5AAEFF),
    shadow: Color(0xFF0F172A),
    scrim: Color(0xFF0F172A),
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF5AAEFF),
    onPrimary: Color(0xFF00213F),
    primaryContainer: Color(0xFF0B3A6B),
    onPrimaryContainer: Color(0xFFD6E9FF),
    secondary: Color(0xFFB4BAC6),
    onSecondary: Color(0xFF1E2330),
    secondaryContainer: Color(0xFF2A3345),
    onSecondaryContainer: Color(0xFFDDE2EC),
    tertiary: Color(0xFF5CD0DA),
    onTertiary: Color(0xFF00363B),
    error: Color(0xFFFF8A7E),
    onError: Color(0xFF3D0A05),
    errorContainer: Color(0xFF5C1A14),
    onErrorContainer: Color(0xFFFFDAD5),
    surface: Color(0xFF0B1120),
    onSurface: Color(0xFFE6EAF2),
    onSurfaceVariant: Color(0xFF9AA7BD),
    surfaceContainerLowest: Color(0xFF080D19),
    surfaceContainerLow: Color(0xFF111A2C),
    surfaceContainer: Color(0xFF172238),
    surfaceContainerHigh: Color(0xFF1E2A42),
    surfaceContainerHighest: Color(0xFF26334D),
    outline: Color(0xFF8392AB),
    outlineVariant: Color(0xFF24314A),
    inverseSurface: Color(0xFFE6EAF2),
    onInverseSurface: Color(0xFF0F172A),
    inversePrimary: Color(0xFF0A6DD9),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  static TextTheme _textTheme(ColorScheme scheme) {
    final strong = scheme.onSurface;
    final muted = scheme.onSurfaceVariant;
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: strong,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: strong,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: strong,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: strong,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: strong,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: strong,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: strong,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: strong,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: strong,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: muted,
      ),
    );
  }

  ThemeData _build(ColorScheme scheme, AppPalette palette) {
    // La police doit être posée ici : `ThemeData.fontFamily` ne l'applique
    // qu'au `textTheme`, pas aux styles repris par les thèmes de composants
    // (barre de titre, boutons, onglets).
    final text = _textTheme(scheme).apply(fontFamily: fontFamily);
    const controlShape = RoundedRectangleBorder(borderRadius: AppRadius.mdAll);
    const controlSize = Size(64, 48);
    final subtleBorder = BorderSide(
      color: scheme.outline.withValues(alpha: 0.35),
    );

    OutlineInputBorder fieldBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      extensions: [palette],
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: scheme.outlineVariant,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: text.titleMedium,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
        actionsIconTheme: IconThemeData(
          color: scheme.onSurfaceVariant,
          size: 22,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.outline),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle: text.bodyMedium?.copyWith(color: scheme.primary),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: fieldBorder(scheme.outlineVariant),
        enabledBorder: fieldBorder(scheme.outlineVariant),
        disabledBorder: fieldBorder(scheme.outlineVariant),
        focusedBorder: fieldBorder(scheme.primary, 1.6),
        errorBorder: fieldBorder(scheme.error),
        focusedErrorBorder: fieldBorder(scheme.error, 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: controlSize,
          shape: controlShape,
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: controlSize,
          shape: controlShape,
          textStyle: text.labelLarge,
          foregroundColor: scheme.onSurface,
          side: subtleBorder,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: controlShape,
          textStyle: text.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: controlSize,
          shape: controlShape,
          textStyle: text.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        extendedTextStyle: text.labelLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: text.labelSmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: text.labelSmall,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelMedium,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        deleteIconColor: scheme.onSurfaceVariant,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        textStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          textStyle: text.labelMedium,
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: subtleBorder,
          shape: controlShape,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
        circularTrackColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: AppRadius.smAll,
        ),
        textStyle: text.labelSmall?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }
}
