import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/features/auth/domain/entities/auth_user.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isSubmitting = false,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? error;
  final bool isSubmitting;

  static const Object _unset = Object();

  AuthState copyWith({
    AuthStatus? status,
    Object? user = _unset,
    String? error,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: identical(user, _unset) ? this.user : user as AuthUser?,
      error: clearError ? null : error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [status, user, error, isSubmitting];
}