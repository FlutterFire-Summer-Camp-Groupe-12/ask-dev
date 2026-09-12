import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:askdev/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:askdev/features/auth/domain/entities/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemoteDataSource implements AuthRemoteDataSource {
  _FakeRemoteDataSource({this.error, this.googleResult});

  Object? error;
  Future<AuthUser?>? googleResult;
  AuthUser? user;
  bool googleSignedOut = false;

  @override
  Stream<AuthUser?> userChanges() => const Stream.empty();

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    if (error != null) throw error!;
    return user!;
  }

  @override
  Future<AuthUser> signInWithIdentifier(String identifier, String password) async {
    if (error != null) throw error!;
    return user!;
  }

  @override
  Future<AuthUser> signUpWithEmail(String email, String password, String pseudo) async {
    if (error != null) throw error!;
    return user!;
  }

  @override
  Future<AuthUser?> signInWithGoogle() async => googleResult;

  @override
  Future<void> signOut() async {
    googleSignedOut = true;
  }
}

void main() {
  const user = AuthUser(uid: 'u1', email: 'a@b.com');

  group('AuthRepositoryImpl', () {
    test('maps email-already-in-use to a Failure', () async {
      final remote = _FakeRemoteDataSource(error: FirebaseAuthException(code: 'email-already-in-use'));
      final repository = AuthRepositoryImpl(remoteDataSource: remote);

      final result = await repository.signUp(pseudo: 'devpro', email: 'a@b.com', password: 'secret');

      String message = '';
      result.fold((failure) => message = failure.message, (_) => fail('Expected failure'));
      expect(message, 'Cet email est déjà utilisé.');
    });

    test('maps wrong-password to a generic credentials Failure', () async {
      final remote = _FakeRemoteDataSource(error: FirebaseAuthException(code: 'wrong-password'));
      final repository = AuthRepositoryImpl(remoteDataSource: remote);

      final result = await repository.signIn(identifier: 'a@b.com', password: 'incorrect');

      String message = '';
      result.fold((failure) => message = failure.message, (_) => fail('Expected failure'));
      expect(message, 'Identifiant ou mot de passe incorrect.');
    });

    test('returns a cancelled Failure when Google sign-in returns null', () async {
      final remote = _FakeRemoteDataSource(googleResult: null);
      final repository = AuthRepositoryImpl(remoteDataSource: remote);

      final result = await repository.signInWithGoogle();

      String message = '';
      result.fold((failure) => message = failure.message, (_) => fail('Expected failure'));
      expect(message, 'Connexion annulée.');
    });

    test('successful sign-in updates current user and status', () async {
      final remote = _FakeRemoteDataSource()..user = user;
      final repository = AuthRepositoryImpl(remoteDataSource: remote);

      final result = await repository.signIn(identifier: 'a@b.com', password: 'secret');

      expect(result.isRight(), isTrue);
      expect(repository.status, AuthStatus.authenticated);
      expect(repository.currentUser?.uid, 'u1');
    });

    test('signOut clears user and sets unauthenticated status', () async {
      final remote = _FakeRemoteDataSource()..user = user;
      final repository = AuthRepositoryImpl(remoteDataSource: remote);
      await repository.signIn(identifier: 'a@b.com', password: 'secret');

      final result = await repository.signOut();

      expect(result.isRight(), isTrue);
      expect(repository.status, AuthStatus.unauthenticated);
      expect(repository.currentUser, isNull);
      expect(remote.googleSignedOut, isTrue);
    });
  });
}