import 'package:askdev/features/profile/data/models/user_profile_model.dart';
import 'package:askdev/features/profile/data/sources/user_remote_data_source.dart';
import 'package:askdev/features/profile/presentation/manager/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUserDataSource implements UserRemoteDataSource {
  UserProfileModel? profile;
  UserProfileModel? saved;

  @override
  Future<void> saveUserProfile(UserProfileModel p) async {
    saved = p;
    profile = p;
  }

  @override
  Future<String?> emailForPseudo(String pseudo) async => 'devpro@example.com';

  @override
  Future<UserProfileModel?> userProfile(String uid) async => profile;
}

void main() {
  test('loadProfile falls back to a local profile when the doc is missing', () async {
    final cubit = ProfileCubit(dataSource: _FakeUserDataSource());
    await cubit.loadProfile('u1', fallbackPseudo: 'devpro', fallbackEmail: 'dev@example.com');

    final profile = cubit.state.profile;
    expect(profile, isNotNull);
    expect(profile!.pseudo, 'devpro');
    expect(profile.email, 'dev@example.com');
  });

  test('updateProfile trims skills, drops empties and persists', () async {
    final source = _FakeUserDataSource();
    final cubit = ProfileCubit(dataSource: source);
    await cubit.loadProfile('u1', fallbackPseudo: 'devpro');
    await cubit.updateProfile(
      pseudo: '  devpro  ',
      bio: '  Biographie  ',
      skills: ['  Flutter  ', ' ', 'Dart'],
    );

    final profile = cubit.state.profile;
    expect(profile?.pseudo, 'devpro');
    expect(profile?.bio, 'Biographie');
    expect(profile?.skills, ['Flutter', 'Dart']);
    expect(source.saved?.skills, ['Flutter', 'Dart']);
  });
}