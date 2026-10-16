import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/widgets/display/widget_pet_image.dart';

/// Altura da área de imagem no visualizador flutuante.
const double _kGalleryHeight = 440;

/// Espaçamento interno do diálogo nas bordas da tela.
const double _kDialogInsetPadding = 24;

/// Espaçamento entre o contador e a imagem.
const double _kCounterSpacing = 12;

/// Visualizador de imagem em janela flutuante.
///
/// Mostra a imagem inteira sem distorção (BoxFit.contain), em um tamanho
/// razoável sobreposto à tela de detalhes. Permite navegar entre as fotos com
/// deslize (carousel). Pode ser fechado com o botão de fechar (X) ou pressionando
/// o botão Voltar do aparelho.
class WGPetFullScreenGallery extends StatefulWidget {
  const WGPetFullScreenGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.onClose,
  });

  /// Lista de URLs das imagens.
  final List<String> images;

  /// Índice da imagem que deve ser exibida primeiro.
  final int initialIndex;

  /// Callback chamado quando o visualizador é fechado.
  final VoidCallback? onClose;

  @override
  State<WGPetFullScreenGallery> createState() =>
      _WGPetFullScreenGalleryState();
}

class _WGPetFullScreenGalleryState extends State<WGPetFullScreenGallery> {
  // Índice da imagem atualmente exibida no carousel.
  late int _currentIndex;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Atualiza o índice quando o usuário desliza o carousel.
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = widget.images.length > 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(_kDialogInsetPadding),
      child: PopScope(
        onPopInvokedWithResult: (_, _) {
          widget.onClose?.call();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CONTADOR DE FOTOS (superior direito)
            if (hasMultipleImages)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

            // PÁGINA DE IMAGENS (carousel com imagem inteira)
            SizedBox(
              width: double.infinity,
              height: _kGalleryHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return Semantics(
                    label: 'Imagem ${index + 1} de ${widget.images.length}',
                    child: WGPetImage(
                      url: widget.images[index],
                      memCacheWidth: 1080,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: _kCounterSpacing),

            // BOTÃO FECHAR
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onClose?.call();
              },
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              label: Text(
                SharedStrings.FECHAR,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
