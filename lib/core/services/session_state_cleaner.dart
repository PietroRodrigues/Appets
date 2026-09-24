import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/my_publications_service.dart';

/// Zera os estados globais em memória (favoritos e publicações) quando a
/// sessão muda ou é perdida sem logout explícito — token expirado/revogado,
/// conta trocada ou excluída remotamente.
///
/// Sem isso, os dados da conta anterior continuam na memória (`FavoritesService`
/// e `MyPublicationsService`) e vazam para a próxima sessão. O logout explícito
/// e a exclusão de conta já limpam por conta própria; este observador cobre os
/// caminhos implícitos, reagindo ao `authStateChanges`.
class SessionStateCleaner {
  SessionStateCleaner._();

  static final SessionStateCleaner instance = SessionStateCleaner._();

  String? _lastUid;
  StreamSubscription<User?>? _subscription;

  /// Passa a escutar a autenticação, zerando o estado a cada perda ou
  /// troca de conta. Idempotente: só se inscreve uma vez.
  void attach() {
    _subscription ??= AuthService.instance.authStateChanges.listen(_onAuth);
  }

  /// Cancela a escuta e descarta o histórico de sessão (uso em testes).
  void detach() {
    _subscription?.cancel();
    _subscription = null;
    _lastUid = null;
  }

  void _onAuth(User? user) {
    if (_isSameSession(user)) return;
    _lastUid = user?.uid;
    FavoritesService.instance.reset();
    MyPublicationsService.instance.reset();
  }

  /// Considera a mesma sessão quando o usuário não mudou (ou quando não há
  /// usuário e já estávamos deslogados).
  bool _isSameSession(User? user) {
    if (user == null) return _lastUid == null;
    return user.uid == _lastUid;
  }
}