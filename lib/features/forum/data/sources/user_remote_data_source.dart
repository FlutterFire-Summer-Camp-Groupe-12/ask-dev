import 'package:askdev/features/forum/data/models/user_profile_model.dart';

abstract class UserRemoteDataSource {
  Future<void> saveUserProfile(UserProfileModel profile);

  Future<String?> emailForPseudo(String pseudo);

  Future<UserProfileModel?> userProfile(String uid);
}