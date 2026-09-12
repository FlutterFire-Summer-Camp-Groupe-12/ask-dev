import 'package:askdev/features/profile/data/models/user_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final timestamp = Timestamp.fromMillisecondsSinceEpoch(1700000000000);

  group('UserProfileModel', () {
    test('fromJson converts timestamps and maps all fields', () {
      final model = UserProfileModel.fromJson({
        'uid': 'u1',
        'pseudo': 'devpro',
        'email': 'devpro@example.com',
        'avatarUrl': 'gs://bucket/avatars/a.png',
        'createdAt': timestamp,
        'skills': ['flutter', 'firebase'],
        'bio': 'Développeur Flutter',
      });

      expect(model.uid, 'u1');
      expect(model.pseudo, 'devpro');
      expect(model.email, 'devpro@example.com');
      expect(model.avatarUrl, 'gs://bucket/avatars/a.png');
      expect(model.createdAt, timestamp.toDate());
      expect(model.skills, ['flutter', 'firebase']);
      expect(model.bio, 'Développeur Flutter');
    });

    test('fromJson defaults optional fields when missing', () {
      final model = UserProfileModel.fromJson({
        'uid': 'u1',
        'pseudo': 'devpro',
        'createdAt': timestamp,
      });

      expect(model.email, isNull);
      expect(model.avatarUrl, isNull);
      expect(model.skills, isEmpty);
      expect(model.bio, isNull);
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
        'email': 'devpro@example.com',
        'createdAt': timestamp,
        'skills': ['flutter', 'firebase'],
        'bio': 'Développeur Flutter',
      });

      final back = UserProfileModel.fromJson(model.toJson());

      expect(back.uid, model.uid);
      expect(back.pseudo, model.pseudo);
      expect(back.email, model.email);
      expect(back.createdAt, model.createdAt);
      expect(back.skills, model.skills);
      expect(back.bio, model.bio);
    });

    test('fromJson throws FormatException when createdAt is missing', () {
      expect(
        () => UserProfileModel.fromJson({'uid': 'u1', 'pseudo': 'devpro'}),
        throwsFormatException,
      );
    });
  });
}