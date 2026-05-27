import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_service.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  // Utilisateur courant
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream de l'état de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Inscription Email/Password ─────────────────────────────────────────────
  Future<AuthResult> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String age,
    required String objectif,
    required String avatar,
  }) async {
    try {
      // Créer le compte Firebase
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      // Créer le profil Firestore
      final userModel = UserModel(
        uid: user.uid,
        nom: nom,
        prenom: prenom,
        email: email,
        age: age,
        avatar: avatar,
        objectif: objectif,
        createdAt: DateTime.now(),
      );

      await _userService.createUser(userModel);

      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      print("🚨 ERREUR CRITIQUE DANS REGISTER : $e");
      return AuthResult.error('Une erreur est survenue.');
    }
  }

  // ── Connexion Email/Password ───────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = await _userService.getUser(currentUser!.uid);
      if (userModel == null) {
        return AuthResult.error('Profil introuvable.');
      }

      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Une erreur est survenue.');
    }
  }

  // ── Connexion Google ───────────────────────────────────────────────────────
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.error('Connexion annulée.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Vérifier si l'utilisateur existe déjà
      UserModel? userModel = await _userService.getUser(user.uid);

      if (userModel == null) {
        // Nouveau compte Google
        final nameParts = (user.displayName ?? '').split(' ');
        userModel = UserModel(
          uid: user.uid,
          nom: nameParts.length > 1 ? nameParts.last : '',
          prenom: nameParts.first,
          email: user.email ?? '',
          age: '',
          avatar: 'assets/avatars/avatar.png',
          createdAt: DateTime.now(),
        );
        await _userService.createUser(userModel);
      }

      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Erreur Google : ${e.toString()}');
    }
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Messages d'erreur ─────────────────────────────────────────────────────
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (min. 6 caractères).';
      case 'user-not-found':
        return 'Aucun compte avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'network-request-failed':
        return 'Pas de connexion internet.';
      default:
        return 'Une erreur est survenue. Réessaie.';
    }
  }
}

// ── Résultat d'authentification ───────────────────────────────────────────────
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? error;

  AuthResult._({required this.success, this.user, this.error});

  factory AuthResult.success(UserModel user) =>
      AuthResult._(success: true, user: user);

  factory AuthResult.error(String message) =>
      AuthResult._(success: false, error: message);
}