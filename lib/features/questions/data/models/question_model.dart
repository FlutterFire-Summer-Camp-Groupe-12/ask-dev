import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.authorId,
    required super.authorPseudo,
    required super.createdAt,
    required super.answersCount,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return QuestionModel(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      authorId: (data['authorId'] ?? '') as String,
      authorPseudo: (data['authorPseudo'] ?? 'Anonyme') as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answersCount: (data['answersCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorPseudo': authorPseudo,
      'createdAt': Timestamp.fromDate(createdAt),
      'answersCount': answersCount,
    };
  }
}