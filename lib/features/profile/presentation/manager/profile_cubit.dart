import 'package:askdev/features/profile/data/models/user_profile_model.dart';
import 'package:askdev/features/profile/data/sources/user_remote_data_source.dart';
import 'package:askdev/features/profile/presentation/manager/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UserRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const ProfileState());

  final UserRemoteDataSource _dataSource;

  Future<void> loadProfile(String uid, {String? fallbackPseudo, String? fallbackEmail}) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final profile = await _dataSource.userProfile(uid);
      emit(
        state.copyWith(
          isLoading: false,
          profile: profile ??
              UserProfileModel(
                uid: uid,
                pseudo: fallbackPseudo ?? 'Utilisateur',
                email: fallbackEmail,
                createdAt: DateTime.now(),
              ),
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false, error: 'Impossible de charger le profil.'));
    }
  }

  Future<void> updateProfile({
    required String pseudo,
    required String bio,
    required List<String> skills,
  }) async {
    final current = state.profile;
    if (current == null || state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final updated = UserProfileModel(
        uid: current.uid,
        pseudo: pseudo.trim(),
        email: current.email,
        avatarUrl: current.avatarUrl,
        createdAt: current.createdAt,
        skills: skills.map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        bio: bio.trim(),
      );
      await _dataSource.saveUserProfile(updated);
      emit(state.copyWith(isSaving: false, profile: updated));
    } catch (_) {
      emit(state.copyWith(isSaving: false, error: 'Impossible d\'enregistrer les modifications.'));
    }
  }
}