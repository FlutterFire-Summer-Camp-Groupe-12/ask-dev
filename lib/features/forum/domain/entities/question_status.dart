/// Destination de publication choisie à la fin du formulaire.
enum QuestionStatus {
  /// Relecture privée : la question n'apparaît pas encore dans le fil public.
  review('review', 'Relecture privée', 'Recevoir des retours avant la publication.'),

  /// Publication immédiate dans le fil public.
  published('published', 'Publier maintenant', 'La question est visible par tous.');

  const QuestionStatus(this.storageKey, this.label, this.description);

  final String storageKey;
  final String label;
  final String description;

  static const QuestionStatus fallback = QuestionStatus.published;

  static QuestionStatus fromStorage(Object? value) {
    for (final status in QuestionStatus.values) {
      if (status.storageKey == value) return status;
    }
    return fallback;
  }
}
