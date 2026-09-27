import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/display/widget_pet_image.dart';

/// Galeria de fotos reutilizável do pet.
///
/// Exibe as imagens em um [PageView] com indicadores (dots),
/// contador de fotos e suporte a [Hero]. Sem imagens, mostra o
/// placeholder padrão de pet (ícone em vez de caixa em branco).
class WGPetGallery extends StatefulWidget {
  const WGPetGallery({super.key, required this.images, this.heroTag});

  // PROPERTIES
  final List<String> images;

  /// Tag do [Hero], aplicada à imagem atualmente visível
  /// (não à fixa do índice 0) para evitar tags duplicadas na rota.
  final String? heroTag;

  @override
  State<WGPetGallery> createState() => _WGPetGalleryState();
}

class _WGPetGalleryState extends State<WGPetGallery> {
  // Índice da imagem atualmente exibida na galeria.
  int _currentImage = 0;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WGPetGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length == widget.images.length) return;

    // Sincroniza o índice com a nova lista: se a galeria encolheu
    // abaixo da foto atual, recua para o último índice válido; se
    // esvaziou, volta a 0. O jump é pós-frame porque o didUpdateWidget
    // roda no meio do build.
    final length = widget.images.length;
    var next = _currentImage;
    if (length == 0) {
      next = 0;
    } else if (next >= length) {
      next = length - 1;
    }
    if (next == _currentImage) return;
    _currentImage = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        _pageController.jumpToPage(_currentImage);
      }
    });
  }

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
                  child: widget.images.isEmpty
                      // Galeria sem fotos: mesmo placeholder dos cards.
                      ? const WGPetImage(url: '')
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: widget.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            // Somente a imagem visível participa do Hero
                            // para evitar tags duplicadas, e o voo parte da
                            // foto que o usuário está vendo (não preso ao 0).
                            return WGPetImage(
                              url: widget.images[index],
                              memCacheWidth: 1080,
                              heroTag:
                                  widget.heroTag != null &&
                                      index == _currentImage
                                  ? widget.heroTag
                                  : null,
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),

                // INDICADORES (DOTS)
                if (widget.images.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.images.length, (index) {
                      final isActive = index == _currentImage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 12 : 8,
                        height: isActive ? 12 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? ThemeColors.primary
                              : ThemeColors.secondary.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
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