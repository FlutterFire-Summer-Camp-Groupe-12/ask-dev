import 'package:askdev/features/forum/data/models/question_model.dart';
import 'package:askdev/features/forum/data/sources/question_remote_data_source.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  QuestionRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  static const String collectionPath = 'questions';

  final FirebaseFirestore _firestore;

  @override
  Future<QuestionModel> createQuestion(QuestionDraft draft) async {
    final document = _firestore.collection(collectionPath).doc();
    final now = DateTime.now();
    final question = QuestionModel(
      id: document.id,
      title: draft.title,
      content: draft.content,
      authorId: draft.authorId,
      type: draft.type,
      status: draft.status,
      tags: draft.tags,
      createdAt: now,
      updatedAt: now,
      searchKeywords: draft.searchKeywords,
    );

    // Les dates sont posées par le serveur pour rester cohérentes entre
    // appareils ; le modèle retourné garde l'heure locale, suffisante pour
    // l'affichage immédiat.
    await document.set({
      ...question.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return question;
  }
}
