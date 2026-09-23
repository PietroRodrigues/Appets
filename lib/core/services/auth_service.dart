import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/models/user_model.dart';

/// Encapsula as operações de autenticação do Firebase Auth.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  FirebaseAuth? _debugAuth;
  GoogleSignIn _google = GoogleSignIn();

  FirebaseAuth get _auth => _debugAuth ?? FirebaseAuth.instance;

  /// Permite injetar um Auth de teste (ex.: firebase_auth_mocks).
  @visibleForTesting
  set debugAuth(FirebaseAuth? auth) => _debugAuth = auth;

  /// Permite injetar um Google de teste.
  @visibleForTesting
  set debugGoogle(GoogleSignIn google) => _google = google;

  /// Usuário autenticado no momento (ou `null`).
  User? get currentUser => _auth.currentUser;

  /// Stream de mudanças no estado de autenticação.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Se definido, [waitFirstAuthState] lança o erro informado (testes).
  @visibleForTesting
  Object? debugAuthStateError;

  /// Aguarda o primeiro evento do stream para capturar a sessão
  /// restaurada no cold start, evitando mandar usuário logado para o
  /// login (forçando reautenticação). Com timeout: se o Auth demorar
  /// (ex.: GMS instável), usa a sessão nativa restaurada.
  Future<User?> waitFirstAuthState({
    Duration timeout = const Duration(seconds: 4),
  }) {
    final debugError = debugAuthStateError;
    if (debugError != null) {
      return Future.error(debugError);
    }
    return authStateChanges.first.timeout(timeout, onTimeout: () => currentUser);
  }

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

  // Atualiza a senha do usuário logado.
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  /// Garante a existência do documento do usuário no Firestore.
  ///
  /// Grava [user] com `merge` (upsert): cria o doc se ainda não existir
  /// (ex.: primeiro acesso) e, se já existir, atualiza apenas os campos de
  /// identidade sem sobrescrever favoritos/publicações nem a data de
  /// criação. Sem leitura prévia: atômico e idempotente (double-tap não
  /// perde dados). Retorna o [UserModel] gravado.
  Future<UserModel> ensureUserDocument(UserModel user) async {
    await FirestoreService.instance.createUser(user);
    return user;
  }

  /// Indica se a conta atual usa o provedor de e-mail/senha.
  bool get usesPasswordProvider {
    final user = _auth.currentUser;
    return user?.providerData.any((info) => info.providerId == 'password') ??
        false;
  }

  /// Indica se a conta atual foi criada com o Google.
  bool get usesGoogleProvider {
    final user = _auth.currentUser;
    return user?.providerData.any((info) => info.providerId == 'google.com') ??
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
  //
  // O signOut do Firebase é realizado num finally: mesmo que o signOut do
  // Google falhe (ex.: sem rede), o usuário nunca fica logado no app.
  Future<void> logout() async {
    try {
      await _google.signOut();
    } finally {
      await _auth.signOut();
    }
  }
}
