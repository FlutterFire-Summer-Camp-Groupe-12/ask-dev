import 'package:askdev/features/auth/domain/entities/auth_user.dart';

abstract class AuthRemoteDataSource {
  Stream<AuthUser?> userChanges();

  Future<AuthUser> signInWithEmail(String email, String password);

  Future<AuthUser> signInWithIdentifier(String identifier, String password);

  Future<AuthUser> signUpWithEmail(String email, String password, String pseudo);

  Future<AuthUser?> signInWithGoogle();

  Future<void> signOut();
}