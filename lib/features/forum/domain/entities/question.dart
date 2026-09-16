import 'package:askdev/features/forum/domain/entities/question_status.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:equatable/equatable.dart';

class Question extends Equatable {
  const Question({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    required this.answersCount,
    required this.searchKeywords,
    this.type = QuestionType.fallback,
    this.status = QuestionStatus.fallback,
    this.tags = const [],
    this.authorName,
    this.authorPhoto,
  });

  final String id;
  final String title;
  final String content;
  final String authorId;
  final QuestionType type;
  final QuestionStatus status;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int answersCount;
  final List<String> searchKeywords;

  /// Pseudo (ou identité) de l'auteur, dénormalisé pour l'affichage sans
  /// lecture supplémentaire. `null` pour les anciens documents.
  final String? authorName;

  /// URL de l'avatar de l'auteur, dénormalisé comme [authorName].
  final String? authorPhoto;

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    authorId,
    type,
    status,
    tags,
    createdAt,
    updatedAt,
    answersCount,
    searchKeywords,
    authorName,
    authorPhoto,
  ];

  Question copyWith({int? answersCount}) {
    return Question(
      id: id,
      title: title,
      content: content,
      authorId: authorId,
      type: type,
      status: status,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      answersCount: answersCount ?? this.answersCount,
      searchKeywords: searchKeywords,
    );
  }
}
