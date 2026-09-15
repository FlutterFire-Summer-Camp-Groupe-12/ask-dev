import 'package:askdev/features/forum/domain/entities/question_status.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/features/forum/domain/search/search_text.dart';
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

  /// Mots-clés utilisés par la recherche Firestore (`array-contains`),
  /// tirés du titre, des tags et de la description. Voir [SearchText].
  List<String> get searchKeywords => SearchText.buildKeywords(
        title: title,
        tags: tags,
        content: content,
      );

  @override
  List<Object?> get props => [authorId, title, content, type, status, tags];
}
