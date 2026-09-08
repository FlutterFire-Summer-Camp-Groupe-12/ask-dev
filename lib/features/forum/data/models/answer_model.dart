import 'package:askdev/features/forum/data/models/firestore_json.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';

class AnswerModel extends Answer {
  const AnswerModel({
    required super.id,
    required super.content,
    required super.authorId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      createdAt: requireFirestoreDate(json['createdAt'], 'createdAt'),
      updatedAt: requireFirestoreDate(json['updatedAt'], 'updatedAt'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'authorId': authorId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}