import 'package:askdev/features/forum/data/models/answer_model.dart';
import 'package:askdev/features/forum/data/models/question_model.dart';
import 'package:askdev/features/forum/data/sources/question_remote_data_source.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/answer_with_question.dart';
import 'package:askdev/core/error/exception.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_slice.dart';
import 'package:askdev/features/forum/domain/entities/user_activity.dart';
import 'package:askdev/features/forum/domain/search/search_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  QuestionRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  static const String collectionPath = 'questions';

  /// Nombre maximal de lots lus pour remplir une page de recherche. Borne le
  /// coût en lectures quand les mots secondaires filtrent beaucoup.
  static const int maxSearchBatches = 5;

  final FirebaseFirestore _firestore;

  // Derniers documents lus, pour reprendre une pagination sans relire le
  // document curseur. Un curseur absent du cache est relu depuis Firestore.
  final Map<String, DocumentSnapshot<Map<String, dynamic>>> _cursors = {};

  CollectionReference<Map<String, dynamic>> get _questions =>
      _firestore.collection(collectionPath);

  CollectionReference<Map<String, dynamic>> _answersOf(String questionId) =>
      _questions.doc(questionId).collection('answers');

  @override
  Future<QuestionSlice> getRecentQuestions({
    String? startAfter,
    required int limit,
  }) async {
    final query = await _after(
      _questions.orderBy('createdAt', descending: true),
      startAfter,
    );
    // Un document de plus que demandé indique s'il reste une page après.
    final docs = (await query.limit(limit + 1).get()).docs;
    final hasMore = docs.length > limit;
    final page = hasMore ? docs.sublist(0, limit) : docs;
    _remember(page);

    return QuestionSlice(
      questions: page.map(_toModel).toList(),
      nextCursor: hasMore ? page.last.id : null,
    );
  }

  @override
  Future<QuestionSlice> searchQuestions(
    SearchQuery searchQuery, {
    String? startAfter,
    required int limit,
  }) async {
    final anchor = searchQuery.anchor;
    if (anchor == null) return QuestionSlice.empty;

    final base = _questions
        .where('searchKeywords', arrayContains: anchor)
        .orderBy('createdAt', descending: true);
    final matches = <QuestionModel>[];
    var cursor = startAfter;

    for (var batch = 0; batch < maxSearchBatches; batch++) {
      final query = await _after(base, cursor);
      final docs = (await query.limit(limit).get()).docs;
      _remember(docs);

      for (final doc in docs) {
        cursor = doc.id;
        final question = _toModel(doc);
        if (!searchQuery.matches(question.searchKeywords)) continue;
        matches.add(question);
        if (matches.length == limit) {
          return QuestionSlice(questions: matches, nextCursor: doc.id);
        }
      }

      if (docs.length < limit) {
        return QuestionSlice(questions: matches);
      }
    }

    // Lots épuisés sans remplir la page : on rend ce qui a été trouvé et la
    // suite reprendra après le dernier document parcouru.
    return QuestionSlice(questions: matches, nextCursor: cursor);
  }

  Future<Query<Map<String, dynamic>>> _after(
    Query<Map<String, dynamic>> query,
    String? cursorId,
  ) async {
    if (cursorId == null) return query;
    final cursor = _cursors[cursorId] ?? await _questions.doc(cursorId).get();
    if (!cursor.exists) {
      throw NotFoundException(
        message: 'La liste a changé entre-temps. Actualisez pour continuer.',
      );
    }
    return query.startAfterDocument(cursor);
  }

  void _remember(List<DocumentSnapshot<Map<String, dynamic>>> docs) {
    if (_cursors.length > 500) _cursors.clear();
    for (final doc in docs) {
      _cursors[doc.id] = doc;
    }
  }

  QuestionModel _toModel(DocumentSnapshot<Map<String, dynamic>> doc) {
    return QuestionModel.fromJson({'id': doc.id, ...doc.data()!});
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
      authorName: draft.authorName,
      authorPhoto: draft.authorPhoto,
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
  Future<QuestionModel> updateQuestion(
    String questionId,
    QuestionDraft draft,
  ) async {
    final document = _questions.doc(questionId);
    final snapshot = await document.get();
    final current = QuestionModel.fromJson({
      'id': snapshot.id,
      ...snapshot.data()!,
    });

    final updated = QuestionModel(
      id: current.id,
      title: draft.title,
      content: draft.content,
      authorId: current.authorId,
      type: draft.type,
      status: draft.status,
      tags: draft.tags,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      answersCount: current.answersCount,
      searchKeywords: draft.searchKeywords,
      authorName: current.authorName,
      authorPhoto: current.authorPhoto,
    );

    await document.update({
      ...updated.toJson(),
      'createdAt': current.createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return updated;
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    final batch = _firestore.batch();
    // Les réponses vivent en sous-collection : on les supprime avec la
    // question pour ne pas laisser de données orphelines.
    final answers = await _answersOf(questionId).get();
    for (final doc in answers.docs) {
      batch.delete(_answersOf(questionId).doc(doc.id));
    }
    batch.delete(_questions.doc(questionId));
    await batch.commit();
  }

  @override
  Future<List<AnswerModel>> getAnswers(String questionId) async {
    final snapshot = await _answersOf(
      questionId,
    ).orderBy('createdAt', descending: false).get();

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
      authorName: draft.authorName,
      authorPhoto: draft.authorPhoto,
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
    final current = AnswerModel.fromJson({
      'id': snapshot.id,
      ...snapshot.data()!,
    });

    final updated = AnswerModel(
      id: current.id,
      content: content,
      authorId: current.authorId,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      authorName: current.authorName,
      authorPhoto: current.authorPhoto,
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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AnswerModel.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  @override
  Future<UserActivity> getUserActivity(
    String userId, {
    required int recentLimit,
  }) async {
    final ownQuestions = _questions.where('authorId', isEqualTo: userId);
    // Future.wait plutôt que .wait sur record : en cas d'échec, l'erreur
    // d'origine remonte telle quelle au lieu d'être emballée dans un
    // ParallelWaitError que le repository ne saurait pas mapper.
    final results = await Future.wait([
      ownQuestions.count().get(),
      _firestore
          .collectionGroup('answers')
          .where('authorId', isEqualTo: userId)
          .count()
          .get(),
      ownQuestions
          .orderBy('createdAt', descending: true)
          .limit(recentLimit)
          .get(),
    ]);
    final questionsCount = results[0] as AggregateQuerySnapshot;
    final answersCount = results[1] as AggregateQuerySnapshot;
    final recent = results[2] as QuerySnapshot<Map<String, dynamic>>;

    return UserActivity(
      questionsCount: questionsCount.count ?? 0,
      answersCount: answersCount.count ?? 0,
      recentQuestions: recent.docs.map(_toModel).toList(),
    );
  }

  @override
  Future<List<QuestionModel>> getQuestionsByAuthor(String userId) async {
    final snapshot = await _questions
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(_toModel).toList();
  }

  @override
  Future<List<AnswerWithQuestion>> getAnswersByAuthor(String userId) async {
    final snapshot = await _firestore
        .collectionGroup('answers')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    // Charge le titre de chaque question parente. Le document réponse vit
    // sous questions/{questionId}/answers/{answerId} : on extrait l'identifiant
    // du chemin, puis on lit les questions par lots pour limiter les lectures.
    final questionIds = snapshot.docs
        .map((doc) => doc.reference.parent.parent!.id)
        .toSet();
    final titles = <String, String>{};
    for (final id in questionIds) {
      final question = await _questions.doc(id).get();
      if (question.exists) {
        titles[id] = (question.data()?['title'] as String?) ?? '';
      }
    }

    return snapshot.docs.map((doc) {
      final questionId = doc.reference.parent.parent!.id;
      return AnswerWithQuestion(
        answer: AnswerModel.fromJson({'id': doc.id, ...doc.data()}),
        questionId: questionId,
        questionTitle: titles[questionId] ?? '',
      );
    }).toList();
  }
}
