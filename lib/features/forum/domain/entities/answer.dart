import 'package:equatable/equatable.dart';

class Answer extends Equatable {
  const Answer({
    required this.id,
    required this.content,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, content, authorId, createdAt, updatedAt];
}