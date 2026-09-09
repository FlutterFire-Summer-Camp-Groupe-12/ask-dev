/// Extensions utilitaires sur les types de base du Dart.
///
/// Regroupe les petites manipulations répétées dans les écrans :
/// conversions sûres depuis une chaîne, formatage / parsing de dates,
/// et aides courantes sur les chaînes de caractères.
library;

const String _emailPattern = r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$';

final RegExp _emailRegExp = RegExp(_emailPattern);
final RegExp _whitespaceRegExp = RegExp(r'\s+');
final RegExp _dateTokenRegExp = RegExp(
  'yyyy|yy|MMMM|MMM|MM|M|EEEE|EEE|dd|d|HH|H|hh|h|mm|m|ss|s|a',
);
final RegExp _localDateRegExp = RegExp(
  r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?$',
);

const List<String> _frenchMonths = <String>[
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

const List<String> _frenchWeekdays = <String>[
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// Conversions sûres depuis une chaîne : retournent `null` au lieu de lever
/// une exception quand la chaîne ne contient pas un nombre valide.
extension StringNumberParsing on String {
  /// Convertit la chaîne en [int], ou `null` si la conversion échoue.
  ///
  /// Les espaces autour de la valeur sont ignorés (`' 42 '` donne `42`).
  int? get toIntOrNull => int.tryParse(trim());

  /// Convertit la chaîne en [double], ou `null` si la conversion échoue.
  ///
  /// Accepte la virgule comme séparateur décimal (`'3,14'` donne `3.14`).
  double? get toDoubleOrNull => double.tryParse(trim().replaceFirst(',', '.'));

  /// Convertit la chaîne en [num], ou `null` si la conversion échoue.
  num? get toNumOrNull => toIntOrNull ?? toDoubleOrNull;
}

/// Conversions sûres vers [int] depuis une chaîne éventuellement nulle.
///
/// ```dart
/// IntParsing.tryParse(controller.text); // int? , jamais d'exception
/// ```
extension IntParsing on int {
  /// Retourne l'entier contenu dans [source], ou `null` si [source] est nulle,
  /// vide ou n'est pas un entier valide.
  static int? tryParse(String? source) => source?.toIntOrNull;

  /// Comme [tryParse], mais retourne [fallback] au lieu de `null`.
  static int parseOr(String? source, int fallback) =>
      tryParse(source) ?? fallback;
}

/// Conversions sûres vers [double] depuis une chaîne éventuellement nulle.
extension DoubleParsing on double {
  /// Retourne le décimal contenu dans [source], ou `null` si [source] est
  /// nulle, vide ou n'est pas un décimal valide.
  static double? tryParse(String? source) => source?.toDoubleOrNull;

  /// Comme [tryParse], mais retourne [fallback] au lieu de `null`.
  static double parseOr(String? source, double fallback) =>
      tryParse(source) ?? fallback;
}

/// Formatage des dates et comparaison relative ("il y a 2 heures").
extension DateTimeExtensions on DateTime {
  /// Formate la date selon un [pattern] simple.
  ///
  /// Jetons reconnus : `yyyy`, `yy`, `MMMM`, `MMM`, `MM`, `M`, `EEEE`, `EEE`,
  /// `dd`, `d`, `HH`, `H`, `hh`, `h`, `mm`, `m`, `ss`, `s`, `a`.
  ///
  /// ```dart
  /// DateTime(2026, 9, 9).format();             // 09/09/2026
  /// DateTime(2026, 9, 9).format('d MMMM yyyy'); // 9 septembre 2026
  /// ```
  String format([String pattern = 'dd/MM/yyyy']) {
    return pattern.replaceAllMapped(_dateTokenRegExp, (match) {
      switch (match[0]) {
        case 'yyyy':
          return year.toString().padLeft(4, '0');
        case 'yy':
          return _twoDigits(year % 100);
        case 'MMMM':
          return _frenchMonths[month - 1];
        case 'MMM':
          return _frenchMonths[month - 1].substring(0, 3);
        case 'MM':
          return _twoDigits(month);
        case 'M':
          return month.toString();
        case 'EEEE':
          return _frenchWeekdays[weekday - 1];
        case 'EEE':
          return _frenchWeekdays[weekday - 1].substring(0, 3);
        case 'dd':
          return _twoDigits(day);
        case 'd':
          return day.toString();
        case 'HH':
          return _twoDigits(hour);
        case 'H':
          return hour.toString();
        case 'hh':
          return _twoDigits(hour % 12 == 0 ? 12 : hour % 12);
        case 'h':
          return (hour % 12 == 0 ? 12 : hour % 12).toString();
        case 'mm':
          return _twoDigits(minute);
        case 'm':
          return minute.toString();
        case 'ss':
          return _twoDigits(second);
        case 's':
          return second.toString();
        case 'a':
          return hour < 12 ? 'AM' : 'PM';
        default:
          return match[0]!;
      }
    });
  }

  /// Date seule, au format `jj/mm/aaaa`.
  String get toDateString => format('dd/MM/yyyy');

  /// Heure seule, au format `hh:mm`.
  String get toTimeString => format('HH:mm');

  /// Date et heure, au format `jj/mm/aaaa hh:mm`.
  String get toDateTimeString => format('dd/MM/yyyy HH:mm');

  /// Représentation ISO 8601, pratique pour le stockage.
  String get toIsoString => toIso8601String();

  /// Vrai si la date tombe le même jour que [other] (heure ignorée).
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Vrai si la date tombe aujourd'hui.
  bool get isToday => isSameDay(DateTime.now());

  /// Vrai si la date tombe hier.
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Décrit l'écart entre cette date et [reference] (maintenant par défaut)
  /// sous une forme lisible : `il y a une seconde`, `il y a 3 jours`,
  /// `dans 2 mois`.
  String timeAgo([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    final difference = now.difference(this);
    final isFuture = difference.isNegative;
    final seconds = difference.abs().inSeconds;

    if (seconds < 5) {
      return isFuture ? 'dans un instant' : "à l'instant";
    }

    final String label;
    if (seconds < 60) {
      label = _relativeLabel(seconds, 'une seconde', 'secondes');
    } else if (seconds < 3600) {
      label = _relativeLabel(seconds ~/ 60, 'une minute', 'minutes');
    } else if (seconds < 86400) {
      label = _relativeLabel(seconds ~/ 3600, 'une heure', 'heures');
    } else if (seconds < 604800) {
      label = _relativeLabel(seconds ~/ 86400, 'un jour', 'jours');
    } else if (seconds < 2592000) {
      label = _relativeLabel(seconds ~/ 604800, 'une semaine', 'semaines');
    } else if (seconds < 31536000) {
      label = _relativeLabel(seconds ~/ 2592000, 'un mois', 'mois');
    } else {
      label = _relativeLabel(seconds ~/ 31536000, 'un an', 'ans');
    }

    return isFuture ? 'dans $label' : 'il y a $label';
  }

  static String _relativeLabel(int count, String singular, String pluralUnit) =>
      count <= 1 ? singular : '$count $pluralUnit';
}

/// Parsing de dates depuis une chaîne.
extension StringDateParsing on String {
  /// Convertit la chaîne en [DateTime], ou `null` si le format est inconnu.
  ///
  /// Accepte l'ISO 8601 (`2026-09-09T10:30:00Z`) ainsi que les formats
  /// `jj/mm/aaaa` et `jj-mm-aaaa`, avec heure optionnelle.
  DateTime? get toDateTimeOrNull {
    final source = trim();
    if (source.isEmpty) return null;

    final iso = DateTime.tryParse(source);
    if (iso != null) return iso;

    final match = _localDateRegExp.firstMatch(source);
    if (match == null) return null;

    final day = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final year = int.parse(match[3]!);
    final hour = int.tryParse(match[4] ?? '') ?? 0;
    final minute = int.tryParse(match[5] ?? '') ?? 0;
    final second = int.tryParse(match[6] ?? '') ?? 0;

    if (month < 1 || month > 12 || day < 1 || day > 31 || hour > 23) {
      return null;
    }

    final date = DateTime(year, month, day, hour, minute, second);
    // Rejette les dates qui débordent (31/02/2026 deviendrait 03/03/2026).
    if (date.day != day || date.month != month) return null;
    return date;
  }
}

/// Aides courantes sur les chaînes de caractères.
extension StringExtensions on String {
  /// Première lettre en majuscule, le reste inchangé.
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Première lettre de chaque mot en majuscule.
  String get capitalizeWords =>
      split(' ').map((word) => word.capitalize).join(' ');

  /// Supprime tous les espaces, y compris ceux à l'intérieur.
  String get removeSpaces => replaceAll(_whitespaceRegExp, '');

  /// Réduit les suites d'espaces à un seul et supprime ceux des extrémités.
  String get collapseSpaces => trim().replaceAll(_whitespaceRegExp, ' ');

  /// Vrai si la chaîne ne contient que des espaces (ou rien).
  bool get isBlank => trim().isEmpty;

  /// Vrai si la chaîne contient autre chose que des espaces.
  bool get isNotBlank => !isBlank;

  /// Vrai si la chaîne ressemble à une adresse email valide.
  bool get isValidEmail => _emailRegExp.hasMatch(trim());

  /// Tronque la chaîne à [maxLength] caractères en ajoutant [ellipsis].
  String truncate(int maxLength, {String ellipsis = '…'}) {
    if (maxLength <= 0 || length <= maxLength) return this;
    return '${substring(0, maxLength).trimRight()}$ellipsis';
  }
}

/// Aides sur les chaînes éventuellement nulles, pour éviter les `?? ''`.
extension NullableStringExtensions on String? {
  /// La chaîne, ou [fallback] si elle est nulle.
  String orEmpty([String fallback = '']) => this ?? fallback;

  /// Vrai si la chaîne est nulle ou ne contient que des espaces.
  bool get isNullOrBlank {
    final value = this;
    return value == null || value.isBlank;
  }

  /// Vrai si la chaîne contient autre chose que des espaces.
  bool get isNotNullOrBlank => !isNullOrBlank;
}
