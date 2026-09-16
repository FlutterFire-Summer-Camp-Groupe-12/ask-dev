import 'package:askdev/core/utils/app_logger.dart';
import 'package:askdev/core/utils/type_extensions.dart';
import 'package:askdev/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:askdev/features/auth/domain/entities/auth_user.dart';
import 'package:askdev/features/profile/data/models/user_profile_model.dart';
import 'package:askdev/features/profile/data/sources/user_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required UserRemoteDataSource userDataSource,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn,
       _userDataSource = userDataSource;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserRemoteDataSource _userDataSource;

  @override
  Stream<AuthUser?> userChanges() =>
      _firebaseAuth.authStateChanges().map(_mapUser);

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    final credentials = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _requireUser(credentials.user);
  }

  @override
  Future<AuthUser> signInWithIdentifier(
    String identifier,
    String password,
  ) async {
    final email = await _resolveEmail(identifier);
    return signInWithEmail(email, password);
  }

  Future<String> _resolveEmail(String identifier) async {
    final input = identifier.trim();
    if (input.isValidEmail) return input;

    final email = await _userDataSource.emailForPseudo(input);
    if (email == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    return email;
  }

  @override
  Future<AuthUser> signUpWithEmail(
    String email,
    String password,
    String pseudo,
  ) async {
    final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Le pseudo sert de nom d'auteur dénormalisé sur les questions/réponses.
    await credentials.user!.updateProfile(displayName: pseudo);
    final user = _requireUser(credentials.user);
    await _userDataSource.saveUserProfile(
      UserProfileModel(
        uid: user.uid,
        pseudo: pseudo,
        email: email,
        createdAt: DateTime.now(),
      ),
    );
    return user;
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    const tag = 'GoogleSignIn';
    AppLog.i(tag, 'Début connexion Google');
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        AppLog.i(tag, 'Connexion annulée par l’utilisateur');
        return null;
      }
      AppLog.d(tag, 'Compte Google sélectionné (${account.email})');
      final authentication = await account.authentication;
      // ponytail: présence des tokens seulement, jamais leur valeur.
      AppLog.d(
        tag,
        'Tokens récupérés '
        '(idToken: ${authentication.idToken != null}, '
        'accessToken: ${authentication.accessToken != null})',
      );
      final credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );
      AppLog.d(tag, 'Connexion à Firebase en cours');
      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = _mapUser(result.user);
      AppLog.i(tag, 'Connexion Google réussie (uid: ${user?.uid})');
      return user;
    } catch (error, stackTrace) {
      AppLog.e(tag, 'Échec connexion Google', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  AuthUser _requireUser(User? user) {
    final mapped = _mapUser(user);
    if (mapped == null) {
      throw StateError('Authenticated without a Firebase user');
    }
    return mapped;
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
