import 'package:askdev/features/forum/data/models/firestore_json.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_status.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    required super.createdAt,
    required super.updatedAt,
    super.type,
    super.status,
    super.tags,
    super.answersCount = 0,
    super.searchKeywords = const [],
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      type: QuestionType.fromStorage(json['type']),
      status: QuestionStatus.fromStorage(json['status']),
      tags: List<String>.from(json['tags'] as List? ?? const []),
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
        'type': type.storageKey,
        'status': status.storageKey,
        'tags': tags,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'answersCount': answersCount,
        'searchKeywords': searchKeywords,
      };
}
