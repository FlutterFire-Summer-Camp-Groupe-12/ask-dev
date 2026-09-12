import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/question_model.dart';

abstract class QuestionRemoteSource {
  Future<List<QuestionModel>> getRecentQuestions();
}

class QuestionRemoteSourceImpl implements QuestionRemoteSource {
  QuestionRemoteSourceImpl(this.firestore);

  final FirebaseFirestore firestore;

  static const _collection = 'questions';

  @override
  Future<List<QuestionModel>> getRecentQuestions() async {
    final snapshot = await firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => QuestionModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }
}