import 'package:askdev/core/utils/firestore_json.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';

class AnswerModel extends Answer {
  const AnswerModel({
    required super.id,
    required super.content,
    required super.authorId,
    required super.createdAt,
    required super.updatedAt,
    super.authorName,
    super.authorPhoto,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      createdAt: requireFirestoreDate(json['createdAt'], 'createdAt'),
      updatedAt: requireFirestoreDate(json['updatedAt'], 'updatedAt'),
      authorName: json['authorName'] as String?,
      authorPhoto: json['authorPhoto'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'authorId': authorId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'authorName': authorName,
    'authorPhoto': authorPhoto,
  };
}
