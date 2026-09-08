import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String authorPseudo;
  final DateTime createdAt;
  final int answersCount;

  const Question({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.authorPseudo,
    required this.createdAt,
    required this.answersCount,
  });

  @override
  List<Object?> get props =>
      [id, title, description, authorId, authorPseudo, createdAt, answersCount];
}