import 'package:askdev/core/utils/firestore_json.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    required super.createdAt,
    required super.updatedAt,
    super.answersCount = 0,
    super.searchKeywords = const [],
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      createdAt: requireFirestoreDate(json['createdAt'], 'createdAt'),
      updatedAt: requireFirestoreDate(json['updatedAt'], 'updatedAt'),
      answersCount: json['answersCount'] as int? ?? 0,
      searchKeywords: List<String>.from(json['searchKeywords'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'authorId': authorId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'answersCount': answersCount,
        'searchKeywords': searchKeywords,
      };
}