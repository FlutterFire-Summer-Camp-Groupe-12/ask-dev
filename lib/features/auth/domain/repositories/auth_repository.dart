import 'package:askdev/core/error/failure.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/features/auth/domain/entities/auth_user.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository implements AuthGateway {
  AuthUser? get currentUser;

  Future<Either<Failure, AuthUser>> signIn({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, AuthUser>> signUp({
    required String pseudo,
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> signInWithGoogle();

  Future<Either<Failure, Unit>> signOut();
}