import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/models/user_model.dart';

/// Concentra a carga inicial da Home: lê o documento do usuário logado e o
/// aplica em favoritos/publicações (serviços dos quais as abas dependem).
///
/// Existe para a splash pré-aquecer esses dados antes de navegar, de modo que
/// a Home monte já carregada — sem a tela "Olá, ..." com spinner aparecendo
/// logo depois da splash (o antigo "flash" entre as telas).
///
/// [load] é deduplicado e NÃO lança: uma falha fica registrada em [error] para
/// a Home exibir o estado de erro com retry. [loaded] marca que a primeira
/// tentativa terminou (com ou sem sucesso).
class HomeDataService {
  HomeDataService._();

  static final HomeDataService instance = HomeDataService._();

  /// Último usuário carregado (ou `null` quando não há sessão).
  UserModel? user;

  /// `true` após a primeira tentativa de carga terminar.
  bool loaded = false;

  /// `true` quando a última tentativa de carga falhou.
  bool error = false;

  Future<void>? _inFlight;

  /// Garante que os dados da Home estejam carregados.
  ///
  /// Chamadas concorrentes compartilham a mesma leitura. Com [force], refaz a
  /// leitura mesmo que já esteja [loaded] (usado no retry e no pull-to-refresh).
  Future<void> load({bool force = false}) {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;
    if (loaded && !force) return Future<void>.value();

    final future = _run();
    _inFlight = future;
    future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
    return future;
  }

  Future<void> _run() async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        user = null;
      } else {
        // Leitura única do documento do usuário: o mesmo model alimenta o
        // header da Home e os serviços de favoritos/publicações das abas.
        user = await FirestoreService.instance.getUser(authUser.uid);
        FavoritesService.instance.applyUser(user);
        await MyPublicationsService.instance.applyUser(user);
      }
      error = false;
    } catch (_) {
      error = true;
    } finally {
      loaded = true;
    }
  }

  /// Zera o estado em memória (logout/troca de sessão; uso em testes).
  void reset() {
    user = null;
    loaded = false;
    error = false;
    _inFlight = null;
  }
}
