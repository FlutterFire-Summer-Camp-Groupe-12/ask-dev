import 'package:askdev/core/utils/firestore_json.dart';
import 'package:askdev/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.pseudo,
    required super.createdAt,
    super.email,
    super.avatarUrl,
    super.skills = const [],
    super.bio,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String,
      pseudo: json['pseudo'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: requireFirestoreDate(json['createdAt'], 'createdAt'),
      skills: List<String>.from(json['skills'] as List? ?? const []),
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'pseudo': pseudo,
        'email': email,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt,
        'skills': skills,
        'bio': bio,
      };
}