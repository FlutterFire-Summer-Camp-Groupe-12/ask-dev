import 'package:askdev/core/utils/type_extensions.dart';
import 'package:askdev/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parsing sûr', () {
    expect(' 42 '.toIntOrNull, 42);
    expect('abc'.toIntOrNull, isNull);
    expect('3,14'.toDoubleOrNull, 3.14);
    expect(IntParsing.tryParse(null), isNull);
    expect(IntParsing.parseOr('x', 7), 7);
    expect(DoubleParsing.tryParse('2.5'), 2.5);
  });

  test('dates', () {
    final d = DateTime(2026, 9, 9, 14, 5, 3);
    expect(d.toDateString, '09/09/2026');
    expect(d.toDateTimeString, '09/09/2026 14:05');
    expect(d.format('d MMMM yyyy'), '9 septembre 2026');
    expect(d.format('EEEE'), 'mercredi');
    expect('09/09/2026 14:05'.toDateTimeOrNull, DateTime(2026, 9, 9, 14, 5));
    expect('2026-09-09T14:05:00'.toDateTimeOrNull, DateTime(2026, 9, 9, 14, 5));
    expect('31/02/2026'.toDateTimeOrNull, isNull);
    expect('pas une date'.toDateTimeOrNull, isNull);
  });

  test('timeAgo', () {
    final now = DateTime(2026, 9, 9, 12);
    expect(now.subtract(const Duration(seconds: 1)).timeAgo(now), "à l'instant");
    expect(now.subtract(const Duration(seconds: 10)).timeAgo(now), 'il y a 10 secondes');
    expect(now.subtract(const Duration(minutes: 1)).timeAgo(now), 'il y a une minute');
    expect(now.subtract(const Duration(hours: 5)).timeAgo(now), 'il y a 5 heures');
    expect(now.subtract(const Duration(days: 1)).timeAgo(now), 'il y a un jour');
    expect(now.subtract(const Duration(days: 40)).timeAgo(now), 'il y a un mois');
    expect(now.subtract(const Duration(days: 400)).timeAgo(now), 'il y a un an');
    expect(now.add(const Duration(days: 3)).timeAgo(now), 'dans 3 jours');
  });

  test('chaînes', () {
    expect('bonjour'.capitalize, 'Bonjour');
    expect('jean paul'.capitalizeWords, 'Jean Paul');
    expect(' a b\tc '.removeSpaces, 'abc');
    expect('  a   b  '.collapseSpaces, 'a b');
    expect('  '.isBlank, isTrue);
    expect('dev@askdev.io'.isValidEmail, isTrue);
    expect('dev@askdev'.isValidEmail, isFalse);
    expect('abcdefgh'.truncate(4), 'abcd…');
    expect(null.orEmpty(), '');
    expect((null as String?).isNullOrBlank, isTrue);
  });

  test('validateurs', () {
    expect(Validators.email(''), 'Email requis');
    expect(Validators.email('nope'), 'Email invalide');
    expect(Validators.email(' dev@askdev.io '), isNull);
    expect(Validators.password(''), 'Mot de passe requis');
    expect(Validators.password('12345'), '6 caractères minimum');
    expect(Validators.password('123456'), isNull);
    expect(Validators.password('abcdef', requireStrong: true), 'Le mot de passe doit contenir un chiffre');
    expect(Validators.confirmPassword('a', 'b'), 'Les mots de passe ne correspondent pas');
    expect(Validators.required(' ', label: 'Nom'), 'Nom requis');
    expect(Validators.combine([(v) => Validators.required(v), (v) => Validators.maxLength(v, 2)])('abc'), '2 caractères maximum');
  });
}
