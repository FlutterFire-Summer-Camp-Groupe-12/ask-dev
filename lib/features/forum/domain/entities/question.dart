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
      ];
}
