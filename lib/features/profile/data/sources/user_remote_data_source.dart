import 'dart:io';

import 'package:askdev/features/profile/data/models/user_profile_model.dart';

abstract class UserRemoteDataSource {
  Future<void> saveUserProfile(UserProfileModel profile);

  Future<String?> emailForPseudo(String pseudo);

  Future<UserProfileModel?> userProfile(String uid);

  /// Upload l'avatar dans le stockage, met à jour la photo Firebase Auth et
  /// le document profil. Retourne l'URL publique de la photo.
  Future<String> saveAvatar(String uid, File file);
}
