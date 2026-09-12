import 'dart:async';

import 'package:askdev/core/error/failure.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/features/auth/domain/entities/auth_user.dart';
import 'package:askdev/features/auth/domain/repositories/auth_repository.dart';
import 'package:askdev/features/auth/presentation/manager/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(const AuthState()) {
    _watchStatus();
  }

  final AuthRepository _repository;

  StreamSubscription<AuthStatus>? _statusSubscription;

  void _watchStatus() {
    _statusSubscription = _repository.statusStream.listen((status) {
      emit(state.copyWith(status: status, user: _repository.currentUser));
    });
  }

  Future<void> signIn({required String identifier, required String password}) {
    return _apply(() => _repository.signIn(identifier: identifier, password: password));
  }

  Future<void> signUp({
    required String pseudo,
    required String email,
    required String password,
  }) {
    return _apply(
      () => _repository.signUp(pseudo: pseudo, email: email, password: password),
    );
  }

  Future<void> signInWithGoogle() => _apply(_repository.signInWithGoogle);

  Future<void> signOut() async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _repository.signOut();
    result.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, error: failure.message)),
      (_) => emit(
        state.copyWith(isSubmitting: false, status: AuthStatus.unauthenticated, user: null),
      ),
    );
  }

  Future<void> _apply(Future<Either<Failure, AuthUser>> Function() action) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await action();
    result.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, error: failure.message)),
      (user) => emit(
        state.copyWith(isSubmitting: false, status: AuthStatus.authenticated, user: user),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    await super.close();
  }
}