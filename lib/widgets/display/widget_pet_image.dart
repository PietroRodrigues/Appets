import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Imagem de um pet que aceita tanto URLs remotas (Firebase Storage)
/// quanto caminhos de assets locais.
///
/// Permite que os dados reais (URLs de armazenamento) sejam exibidos
/// da mesma forma que os assets usados durante o desenvolvimento.
///
/// URLs remotas passam pelo cache em disco ([AppImageCache]): após o
/// primeiro download a imagem fica local no aparelho. O [memCacheWidth]
/// controla o tamanho da decodificação em memória conforme a superfície
/// (cards menores que a galeria).
class WGPetImage extends StatelessWidget {
  const WGPetImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.heroTag,
    this.memCacheWidth,
  });

  // PROPERTIES
  final String url;
  final BoxFit fit;

  /// Tag opcional para a animação [Hero].
  final String? heroTag;

  /// Largura usada para decodificar a rede em memória.
  /// Cards usam ~480; galeria/detalhe usam ~1080.
  final int? memCacheWidth;

  // UI
  bool get _isNetwork {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();

    final tag = heroTag;
    if (tag == null) return image;

    return Hero(tag: tag, child: image);
  }

  Widget _buildImage() {
    if (url.isEmpty) {
      return const _WGPetImagePlaceholder();
    }

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: url,
        cacheManager: AppImageCache.instance.manager,
        memCacheWidth: memCacheWidth,
        fit: fit,
        errorWidget: (_, _, _) => const _WGPetImagePlaceholder(),
        placeholder: (_, _) =>
            const _WGPetImagePlaceholder(showIndicator: true),
      );
    }

    return Image.asset(url, fit: fit);
  }
}

/// Placeholder exibido quando uma imagem de pet não está disponível.
class _WGPetImagePlaceholder extends StatelessWidget {
  const _WGPetImagePlaceholder({this.showIndicator = false});

  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColors.surface,
      alignment: Alignment.center,
      child: showIndicator
          ? const CircularProgressIndicator(color: ThemeColors.primary)
          : const Icon(Icons.pets, size: 48, color: ThemeColors.hint),
    );
  }
}