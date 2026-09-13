/// Nature de la question, demandée en premier dans le formulaire.
///
/// La valeur persistée dans Firestore est [storageKey] : elle reste stable
/// même si le libellé affiché change.
enum QuestionType {
  howTo('how-to', 'Comment faire / Dépannage', 'Un problème concret à résoudre.'),
  concept('concept', 'Explication / Concept', 'Comprendre comment ou pourquoi ça marche.'),
  comparison('comparison', 'Comparaison / Choix', 'Départager plusieurs approches ou outils.'),
  bestPractice('best-practice', 'Bonne pratique', 'Chercher la façon recommandée de faire.');

  const QuestionType(this.storageKey, this.label, this.description);

  final String storageKey;
  final String label;
  final String description;

  /// Type par défaut proposé à l'ouverture du formulaire.
  static const QuestionType fallback = QuestionType.howTo;

  /// Relit un type depuis Firestore, en retombant sur [fallback] si la
  /// valeur est absente ou inconnue.
  static QuestionType fromStorage(Object? value) {
    for (final type in QuestionType.values) {
      if (type.storageKey == value) return type;
    }
    return fallback;
  }
}
