import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Cache de disco para as imagens dos pets.
///
/// As URLs do Storage são imutáveis (o arquivo só muda junto com uma URL
/// nova), então a URL serve de chave estável: após o primeiro download a
/// imagem fica local no aparelho, reutilizada em feed, favoritos, minhas
/// publicações, detalhe e prévias de edição.
class AppImageCache {
  AppImageCache._();

  static final AppImageCache instance = AppImageCache._();

  /// Chave do cache em disco (diretório próprio).
  static const String cacheKey = 'petImageCache';

  /// Quantidade máxima de arquivos mantidos no disco.
  static const int maxNrOfCacheObjects = 300;

  /// Validade das imagens em disco.
  static const Duration stalePeriod = Duration(days: 30);

  BaseCacheManager? _manager;

  /// Gerenciador de cache (disco).
  BaseCacheManager get manager {
    return _manager ??= CacheManager(
      Config(
        cacheKey,
        maxNrOfCacheObjects: maxNrOfCacheObjects,
        stalePeriod: stalePeriod,
      ),
    );
  }

  /// Permite injetar um cache de teste (ex.: para evitar rede).
  @visibleForTesting
  set debugManager(BaseCacheManager? manager) => _manager = manager;
}