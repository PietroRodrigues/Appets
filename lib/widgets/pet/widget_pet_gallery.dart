import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Galeria de fotos reutilizável do pet.
///
/// Exibe as imagens em um [PageView] com indicadores (dots),
/// contador de fotos e suporte a [Hero] na primeira imagem.
class AppPetGallery extends StatefulWidget {
  const AppPetGallery({
    super.key,
    required this.images,
    this.heroTag,
  });

  // PROPERTIES
  final List<String> images;

  /// Tag do [Hero] aplicada somente à primeira imagem
  /// para evitar tags duplicadas na mesma rota.
  final String? heroTag;

  @override
  State<AppPetGallery> createState() => _AppPetGalleryState();
}

class _AppPetGalleryState extends State<AppPetGallery> {
  // Índice da imagem atualmente exibida na galeria.
  int _currentImage = 0;

  // UI
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: Container(
        color: ThemeColors.surface,
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final image = Image.asset(
                        widget.images[index],
                        fit: BoxFit.contain,
                      );

                      // Somente a primeira imagem participa
                      // do Hero para evitar tags duplicadas.
                      if (widget.heroTag == null || index != 0) {
                        return image;
                      }

                      return Hero(
                        tag: widget.heroTag!,
                        child: image,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // INDICADORES (DOTS)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (index) {
                      final isActive = index == _currentImage;
                      return AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        width: isActive ? 12 : 8,
                        height: isActive ? 12 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? ThemeColors.primary
                              : ThemeColors.secondary
                                  .withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // CONTADOR DE FOTOS
            if (widget.images.length > 1)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImage + 1}/${widget.images.length}',
                    style: ThemeTextStyles.caption.copyWith(
                      color: ThemeColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
