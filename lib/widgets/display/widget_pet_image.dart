import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Imagem de um pet que aceita tanto URLs remotas (Firebase Storage)
/// quanto caminhos de assets locais.
///
/// Permite que os dados reais (URLs de armazenamento) sejam exibidos
/// da mesma forma que os assets usados durante o desenvolvimento.
class WGPetImage extends StatelessWidget {
  const WGPetImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.heroTag,
  });

  // PROPERTIES
  final String url;
  final BoxFit fit;

  /// Tag opcional para a animação [Hero].
  final String? heroTag;

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
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, _, _) => const _WGPetImagePlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _WGPetImagePlaceholder(showIndicator: true);
        },
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
