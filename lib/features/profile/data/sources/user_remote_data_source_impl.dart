import 'dart:io';

import 'package:askdev/features/profile/data/models/user_profile_model.dart';
import 'package:askdev/features/profile/data/sources/user_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required SupabaseClient supabase,
    required String bucketId,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _supabase = supabase,
       _bucketId = bucketId,
       _auth = auth;

  static const Map<String, String> _contentTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'heic': 'image/heic',
  };

  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase;
  final String _bucketId;
  final FirebaseAuth _auth;

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

  @override
  Future<String> saveAvatar(String uid, File file) async {
    final extension = _extensionOf(file.path);
    final path =
        'avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage.from(_bucketId).upload(
      path,
      file,
      fileOptions: FileOptions(contentType: _contentTypes[extension]),
    );
    // ponytail: URL publique, suppose bucket en lecture publique.
    final url = _supabase.storage.from(_bucketId).getPublicUrl(path);

    await _auth.currentUser?.updateProfile(photoURL: url);

    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.update({'avatarUrl': url});
    } else {
      // Comptes sans profil Firestore (anciens comptes, connexion Google).
      final user = _auth.currentUser;
      final pseudo = (user?.displayName ?? user?.email ?? 'Utilisateur').trim();
      await docRef.set(
        UserProfileModel(
          uid: uid,
          pseudo: pseudo.isEmpty ? 'Utilisateur' : pseudo,
          email: user?.email,
          avatarUrl: url,
          createdAt: DateTime.now(),
        ).toJson(),
      );
    }
    return url;
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return 'png';
    final extension = path.substring(dot + 1).toLowerCase();
    return _contentTypes.containsKey(extension) ? extension : 'png';
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
