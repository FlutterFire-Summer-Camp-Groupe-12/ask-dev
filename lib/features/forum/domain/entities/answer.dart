import 'package:equatable/equatable.dart';

class Answer extends Equatable {
  const Answer({
    required this.id,
    required this.content,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorPhoto,
  });

  final String id;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Identité dénormalisée de l'auteur (comme [Question.authorName]).
  final String? authorName;

  /// Avatar dénormalisé de l'auteur.
  final String? authorPhoto;

  @override
  List<Object?> get props => [
    id,
    content,
    authorId,
    createdAt,
    updatedAt,
    authorName,
    authorPhoto,
  ];
}
