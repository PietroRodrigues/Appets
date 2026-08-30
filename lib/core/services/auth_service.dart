import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/models/user_model.dart';

/// Encapsula as operações de autenticação do Firebase Auth.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  /// Usuário autenticado no momento (ou `null`).
  User? get currentUser => _auth.currentUser;

  /// Stream de mudanças no estado de autenticação.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Cria uma conta com e-mail e senha.
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Autentica com e-mail e senha.
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Autentica com a conta Google; retorna `null` se o usuário cancelar.
  Future<UserCredential?> loginWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // Envia um e-mail de recuperação de senha.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Atualiza o nome exibido do usuário no perfil do Firebase Auth.
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  /// Garante a existência do documento do usuário no Firestore.
  ///
  /// Se o documento ainda não existir (ex.: primeiro acesso via Google),
  /// cria-o com [user]. Retorna o [UserModel] persistido.
  Future<UserModel> ensureUserDocument(UserModel user) async {
    final existing = await FirestoreService().getUser(user.id);
    if (existing != null) return existing;

    await FirestoreService().createUser(user);
    return user;
  }

  /// Indica se a conta atual usa o provedor de e-mail/senha.
  bool get usesPasswordProvider {
    final user = _auth.currentUser;
    return user?.providerData.any(
          (info) => info.providerId == 'password',
        ) ??
        false;
  }

  /// Indica se a conta atual foi criada com o Google.
  bool get usesGoogleProvider {
    final user = _auth.currentUser;
    return user?.providerData.any(
          (info) => info.providerId == 'google.com',
        ) ??
        false;
  }

  /// Reautentica o usuário atual com a senha informada.
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  /// Reautentica o usuário atual reabrindo o seletor de conta Google.
  ///
  /// Retorna `false` se o usuário cancelar. Lança erro se a conta
  /// escolhida for diferente da que está logada (`user-mismatch`).
  Future<bool> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final googleUser = await _google.signIn();
    if (googleUser == null) return false;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
    return true;
  }

  /// Exclui a conta do usuário logado no Firebase Auth.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  // Desconecta o usuário do Google e do Firebase Auth.
  Future<void> logout() async {
    await _google.signOut();
    await _auth.signOut();
  }
}
