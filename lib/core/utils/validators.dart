import 'type_extensions.dart';

/// Validateurs de formulaires partagés par tous les écrans.
///
/// Chaque fonction suit le contrat attendu par `TextFormField.validator` :
/// elle retourne le message d'erreur à afficher, ou `null` si la valeur
/// est valide.
///
/// ```dart
/// TextFormField(validator: Validators.email)
/// TextFormField(validator: (v) => Validators.password(v, minLength: 8))
/// ```
abstract final class Validators {
  /// Longueur minimale d'un mot de passe (minimum imposé par Firebase Auth).
  static const int passwordMinLength = 6;

  /// Valide une adresse email : requise et bien formée.
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email requis';
    if (!email.isValidEmail) return 'Email invalide';
    return null;
  }

  /// Valide un identifiant de connexion : email ou pseudo, requis.
  static String? identifier(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Email ou pseudo requis';
    return null;
  }

  /// Valide un pseudo : requis, d'au moins 3 caractères, sans espaces.
  static String? pseudo(String? value) {
    final pseudo = value?.trim() ?? '';
    if (pseudo.isEmpty) return 'Pseudo requis';
    if (pseudo.length < 3) return '3 caractères minimum';
    if (pseudo.contains(RegExp(r'\s'))) return 'Le pseudo ne doit pas contenir d\'espaces';
    return null;
  }

  /// Valide un mot de passe : requis et d'au moins [minLength] caractères.
  ///
  /// Si [requireStrong] est vrai, le mot de passe doit aussi contenir une
  /// lettre et un chiffre.
  static String? password(
    String? value, {
    int minLength = passwordMinLength,
    bool requireStrong = false,
  }) {
    final password = value ?? '';
    if (password.isEmpty) return 'Mot de passe requis';
    if (password.length < minLength) return '$minLength caractères minimum';
    if (requireStrong) {
      if (!password.contains(RegExp(r'[A-Za-z]'))) {
        return 'Le mot de passe doit contenir une lettre';
      }
      if (!password.contains(RegExp(r'\d'))) {
        return 'Le mot de passe doit contenir un chiffre';
      }
    }
    return null;
  }

  /// Valide la confirmation d'un mot de passe : elle doit correspondre à
  /// [original].
  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) {
      return 'Confirmation requise';
    }
    if (value != original) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  /// Valide un champ obligatoire, avec un [label] pour personnaliser le
  /// message (`'Nom requis'`, par exemple).
  static String? required(String? value, {String label = 'Ce champ'}) {
    if (value.isNullOrBlank) return '$label requis';
    return null;
  }

  /// Valide une longueur minimale sur un champ texte obligatoire.
  static String? minLength(
    String? value,
    int length, {
    String label = 'Ce champ',
  }) {
    final requiredError = required(value, label: label);
    if (requiredError != null) return requiredError;
    if (value!.trim().length < length) return '$length caractères minimum';
    return null;
  }

  /// Valide une longueur maximale (le champ vide est accepté).
  static String? maxLength(String? value, int length) {
    if (value != null && value.trim().length > length) {
      return '$length caractères maximum';
    }
    return null;
  }

  /// Combine plusieurs validateurs et retourne la première erreur rencontrée.
  ///
  /// ```dart
  /// validator: Validators.combine([
  ///   (v) => Validators.required(v, label: 'Titre'),
  ///   (v) => Validators.maxLength(v, 120),
  /// ])
  /// ```
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
