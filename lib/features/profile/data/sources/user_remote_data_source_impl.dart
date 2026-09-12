import 'package:askdev/features/profile/data/models/user_profile_model.dart';
import 'package:askdev/features/profile/data/sources/user_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<void> saveUserProfile(UserProfileModel profile) async {
    await _firestore.collection('users').doc(profile.uid).set(profile.toJson());
  }

  @override
  Future<UserProfileModel?> userProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromJson(doc.data()!);
  }

  // ponytail: pseudo uniqueness not enforced app-side, first match wins;
  // add a Firestore unique constraint on pseudo if collisions matter.
  @override
  Future<String?> emailForPseudo(String pseudo) async {
    final snapshot = await _firestore
        .collection('users')
        .where('pseudo', isEqualTo: pseudo)
        .limit(1)
        .get();
    for (final doc in snapshot.docs) {
      return doc.data()['email'] as String?;
    }
    return null;
  }
}