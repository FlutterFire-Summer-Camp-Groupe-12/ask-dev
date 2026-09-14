import 'package:askdev/features/forum/data/models/answer_model.dart';
import 'package:askdev/features/forum/data/models/question_model.dart';
import 'package:askdev/features/forum/data/sources/question_remote_data_source.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  QuestionRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  static const String collectionPath = 'questions';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _questions =>
      _firestore.collection(collectionPath);

  CollectionReference<Map<String, dynamic>> _answersOf(String questionId) =>
      _questions.doc(questionId).collection('answers');

  @override
  Future<List<QuestionModel>> getRecentQuestions() async {
    final snapshot = await _questions
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => QuestionModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  @override
  Future<QuestionModel> createQuestion(QuestionDraft draft) async {
    final document = _questions.doc();
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

  @override
  Future<QuestionModel> getQuestionById(String id) async {
    final doc = await _questions.doc(id).get();
    return QuestionModel.fromJson({'id': doc.id, ...doc.data()!});
  }

  @override
  Future<List<AnswerModel>> getAnswers(String questionId) async {
    final snapshot = await _answersOf(questionId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => AnswerModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  @override
  Future<AnswerModel> createAnswer(String questionId, AnswerDraft draft) async {
    final document = _answersOf(questionId).doc();
    final now = DateTime.now();
    final answer = AnswerModel(
      id: document.id,
      content: draft.content,
      authorId: draft.authorId,
      createdAt: now,
      updatedAt: now,
    );

    // La réponse et l'incrément du compteur partent dans le même batch pour
    // rester cohérents : jamais de réponse sans mise à jour du compteur.
    final batch = _firestore.batch();
    batch.set(document, {
      ...answer.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_questions.doc(questionId), {
      'answersCount': FieldValue.increment(1),
    });
    await batch.commit();

    return answer;
  }

  @override
  Future<AnswerModel> updateAnswer(
    String questionId,
    String answerId,
    String content,
  ) async {
    final document = _answersOf(questionId).doc(answerId);
    final snapshot = await document.get();
    final current = AnswerModel.fromJson({'id': snapshot.id, ...snapshot.data()!});

    final updated = AnswerModel(
      id: current.id,
      content: content,
      authorId: current.authorId,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );

    await document.update({
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return updated;
  }

  @override
  Future<void> deleteAnswer(String questionId, String answerId) async {
    // La suppression et la décrémentation du compteur partent dans le même
    // batch, pour la même raison que createAnswer : jamais de compteur
    // désynchronisé du nombre réel de réponses.
    final batch = _firestore.batch();
    batch.delete(_answersOf(questionId).doc(answerId));
    batch.update(_questions.doc(questionId), {
      'answersCount': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  @override
  Stream<List<AnswerModel>> watchAnswers(String questionId) {
    return _answersOf(questionId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnswerModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }
}