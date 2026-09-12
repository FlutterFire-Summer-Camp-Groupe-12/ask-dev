import 'package:askdev/features/forum/domain/entities/user_profile.dart';
import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final UserProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [profile, isLoading, isSaving, error];
}