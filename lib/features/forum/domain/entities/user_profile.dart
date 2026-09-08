import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.pseudo,
    required this.createdAt,
    this.avatarUrl,
  });

  final String uid;
  final String pseudo;
  final String? avatarUrl;
  final DateTime createdAt;

  @override
  List<Object?> get props => [uid, pseudo, avatarUrl, createdAt];
}