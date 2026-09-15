import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.pseudo,
    required this.createdAt,
    this.email,
    this.avatarUrl,
    this.topics = const [],
    this.bio,
  });

  final String uid;
  final String pseudo;
  final String? email;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<String> topics;
  final String? bio;

  @override
  List<Object?> get props => [
    uid,
    pseudo,
    email,
    avatarUrl,
    createdAt,
    topics,
    bio,
  ];
}
