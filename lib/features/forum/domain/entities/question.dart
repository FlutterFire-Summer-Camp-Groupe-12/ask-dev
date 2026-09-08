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
  });

  final String id;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int answersCount;
  final List<String> searchKeywords;

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        authorId,
        createdAt,
        updatedAt,
        answersCount,
        searchKeywords,
      ];
}