import 'package:askdev/features/forum/data/models/firestore_json.dart';
import 'package:askdev/features/forum/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.pseudo,
    required super.createdAt,
    super.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String,
      pseudo: json['pseudo'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: requireFirestoreDate(json['createdAt'], 'createdAt'),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'pseudo': pseudo,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt,
      };
}