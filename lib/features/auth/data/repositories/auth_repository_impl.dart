import 'dart:async';

import 'package:askdev/core/error/failure.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:askdev/features/auth/domain/entities/auth_user.dart';
import 'package:askdev/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  StreamController<AuthStatus>? _controller;
  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _currentUser;

  @override
  AuthStatus get status => _status;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  String? get currentUserId => _currentUser?.uid;

  @override
  Stream<AuthStatus> get statusStream {
    final existing = _controller;
    if (existing != null) return existing.stream;
    return _createStatusStream();
  }

  Stream<AuthStatus> _createStatusStream() {
    final controller = StreamController<AuthStatus>.broadcast();
    _controller = controller;
    _remoteDataSource.userChanges().listen((user) {
      _setUser(user);
    });
    return controller.stream;
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _run(() => _remoteDataSource.signInWithEmail(email, password));
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _run(() => _remoteDataSource.signUpWithEmail(email, password));
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithGoogle() {
    return _run(_remoteDataSource.signInWithGoogle);
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      _setUser(null);
      return right(unit);
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  Future<Either<Failure, AuthUser>> _run(Future<AuthUser?> Function() action) async {
    try {
      final user = await action();
      if (user == null) {
        return left(const Failure(message: 'Connexion annulée.'));
      }
      _setUser(user);
      return right(user);
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  void _setUser(AuthUser? user) {
    _currentUser = user;
    _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    final controller = _controller;
    if (controller != null && !controller.isClosed) {
      controller.add(_status);
    }
  }

  Failure _toFailure(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return const Failure(message: 'Cet email est déjà utilisé.');
        case 'weak-password':
          return const Failure(message: 'Le mot de passe est trop faible (6 caractères minimum).');
        case 'invalid-email':
        case 'invalid-credential':
        case 'invalid-login-credentials':
        case 'user-not-found':
        case 'wrong-password':
          return const Failure(message: 'Email ou mot de passe incorrect.');
        case 'network-request-failed':
          return const Failure(message: 'Connexion réseau impossible.');
        case 'too-many-requests':
          return const Failure(message: 'Trop de tentatives. Réessayez plus tard.');
        default:
          return Failure(message: error.message ?? 'Une erreur est survenue.');
      }
    }
    return const Failure(message: 'Une erreur est survenue. Réessayez.');
  }
}