import 'package:equatable/equatable.dart';

/// Réponse saisie par l'utilisateur, avant enregistrement.
///
/// Le brouillon ne porte ni identifiant ni dates : ils sont produits par
/// Firestore au moment de la création.
class AnswerDraft extends Equatable {
  const AnswerDraft({required this.content, required this.authorId});

  final String authorId;
  final String content;

  @override
  List<Object?> get props => [authorId, content];
}