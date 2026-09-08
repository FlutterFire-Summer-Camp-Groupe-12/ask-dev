import 'package:askdev/features/forum/data/models/answer_model.dart';
import 'package:askdev/features/forum/data/models/question_model.dart';
import 'package:askdev/features/forum/data/models/user_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final timestamp = Timestamp.fromMillisecondsSinceEpoch(1700000000000);

  group('UserProfileModel', () {
    test('fromJson converts timestamps and maps all fields', () {
      final model = UserProfileModel.fromJson({
        'uid': 'u1',
        'pseudo': 'devpro',
        'avatarUrl': 'gs://bucket/avatars/a.png',
        'createdAt': timestamp,
      });

      expect(model.uid, 'u1');
      expect(model.pseudo, 'devpro');
      expect(model.avatarUrl, 'gs://bucket/avatars/a.png');
      expect(model.createdAt, timestamp.toDate());
    });

    test('fromJson accepts a DateTime input', () {
      final model = UserProfileModel.fromJson({
        'uid': 'u1',
        'pseudo': 'devpro',
        'createdAt': timestamp.toDate(),
      });

      expect(model.createdAt, timestamp.toDate());
    });

    test('toJson round-trips through fromJson', () {
      final model = UserProfileModel.fromJson({
        'uid': 'u1',
        'pseudo': 'devpro',
        'createdAt': timestamp,
      });

      final back = UserProfileModel.fromJson(model.toJson());

      expect(back.uid, model.uid);
      expect(back.pseudo, model.pseudo);
      expect(back.createdAt, model.createdAt);
    });

    test('fromJson throws FormatException when createdAt is missing', () {
      expect(
        () => UserProfileModel.fromJson({'uid': 'u1', 'pseudo': 'devpro'}),
        throwsFormatException,
      );
    });
  });

  group('QuestionModel', () {
    test('fromJson maps all fields including answersCount and searchKeywords', () {
      final model = QuestionModel.fromJson({
        'id': 'q1',
        'title': 'How to use Firebase?',
        'content': 'Body',
        'authorId': 'u1',
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'answersCount': 2,
        'searchKeywords': ['how', 'to', 'use', 'firebase'],
      });

      expect(model.id, 'q1');
      expect(model.title, 'How to use Firebase?');
      expect(model.content, 'Body');
      expect(model.authorId, 'u1');
      expect(model.createdAt, timestamp.toDate());
      expect(model.updatedAt, timestamp.toDate());
      expect(model.answersCount, 2);
      expect(model.searchKeywords, ['how', 'to', 'use', 'firebase']);
    });

    test('fromJson defaults answersCount and searchKeywords when missing', () {
      final model = QuestionModel.fromJson({
        'id': 'q1',
        'title': 'T',
        'content': 'C',
        'authorId': 'u1',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      });

      expect(model.answersCount, 0);
      expect(model.searchKeywords, isEmpty);
    });

    test('toJson round-trips through fromJson with DateTime values', () {
      final model = QuestionModel.fromJson({
        'id': 'q1',
        'title': 'T',
        'content': 'C',
        'authorId': 'u1',
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'answersCount': 1,
        'searchKeywords': ['t'],
      });

      final back = QuestionModel.fromJson(model.toJson());

      expect(back.id, model.id);
      expect(back.title, model.title);
      expect(back.content, model.content);
      expect(back.authorId, model.authorId);
      expect(back.createdAt, model.createdAt);
      expect(back.updatedAt, model.updatedAt);
      expect(back.answersCount, model.answersCount);
      expect(back.searchKeywords, model.searchKeywords);
    });

    test('fromJson throws FormatException when a timestamp is missing', () {
      expect(
        () => QuestionModel.fromJson({
          'id': 'q1',
          'title': 'T',
          'content': 'C',
          'authorId': 'u1',
        }),
        throwsFormatException,
      );
    });
  });

  group('AnswerModel', () {
    test('fromJson maps all fields', () {
      final model = AnswerModel.fromJson({
        'id': 'a1',
        'content': 'Answer body',
        'authorId': 'u2',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      });

      expect(model.id, 'a1');
      expect(model.content, 'Answer body');
      expect(model.authorId, 'u2');
      expect(model.createdAt, timestamp.toDate());
      expect(model.updatedAt, timestamp.toDate());
    });

    test('toJson round-trips through fromJson', () {
      final model = AnswerModel.fromJson({
        'id': 'a1',
        'content': 'Answer body',
        'authorId': 'u2',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      });

      final back = AnswerModel.fromJson(model.toJson());

      expect(back.id, model.id);
      expect(back.content, model.content);
      expect(back.authorId, model.authorId);
      expect(back.createdAt, model.createdAt);
      expect(back.updatedAt, model.updatedAt);
    });
  });
}