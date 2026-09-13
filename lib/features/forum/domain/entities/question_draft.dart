import 'package:askdev/features/forum/domain/entities/question_status.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:equatable/equatable.dart';

/// Question saisie par l'utilisateur, avant enregistrement.
///
/// Le brouillon ne porte ni identifiant ni dates : ils sont produits par
/// Firestore au moment de la création.
class QuestionDraft extends Equatable {
  const QuestionDraft({
    required this.authorId,
    required this.title,
    required this.content,
    required this.type,
    required this.status,
    required this.tags,
  });

  final String authorId;
  final String title;
  final String content;
  final QuestionType type;
  final QuestionStatus status;
  final List<String> tags;

  /// Mots-clés utilisés par la recherche Firestore (`array-contains`).
  ///
  /// Le titre et les tags sont découpés, passés en minuscules et dédupliqués.
  /// Les mots d'une seule lettre sont ignorés, la liste est plafonnée à 30
  /// entrées pour rester sous la limite de taille d'un document.
  List<String> get searchKeywords {
    final words = <String>{};
    for (final word in '$title ${tags.join(' ')}'.toLowerCase().split(RegExp(r'[^a-z0-9+#.]+'))) {
      if (word.length > 1) words.add(word);
      if (words.length >= 30) break;
    }
    return words.toList(growable: false);
  }

  @override
  List<Object?> get props => [authorId, title, content, type, status, tags];
}
