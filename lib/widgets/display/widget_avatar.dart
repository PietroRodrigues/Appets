import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Avatar circular do usuário, com imagem opcional e ação ao tocar.
///
/// Quando a imagem falha ao carregar (URL quebrada/revogada), volta para o
/// ícone de pessoa em vez de deixar um círculo vazio.
class WGAvatar extends StatefulWidget {
  const WGAvatar({
    super.key,
    this.imageUrl,
    this.onTap,
    this.radius = 50,
    this.borderColor,
    this.borderWidth = 3,
    this.shadowColor,
    this.shadowBlurRadius = 8,
    this.debugImageProvider,
  });

  /// URL da imagem do usuário.
  ///
  /// Futuramente será utilizada para carregar a foto
  /// armazenada no Firebase Storage.
  final String? imageUrl;

  /// Ação executada ao tocar no avatar.
  final VoidCallback? onTap;

  /// Tamanho do avatar.
  final double radius;

  /// Cor da borda ao redor do avatar. Quando nula, não há borda.
  final Color? borderColor;

  /// Espessura da borda.
  final double borderWidth;

  /// Cor da sombra projetada. Quando nula, não há sombra.
  final Color? shadowColor;

  /// Raio de desfoque da sombra.
  final double shadowBlurRadius;

  /// Imagem injetada em testes (determinística, sem rede) no lugar da
  /// [NetworkImage] do [imageUrl].
  @visibleForTesting
  final ImageProvider<Object>? debugImageProvider;

  @override
  State<WGAvatar> createState() => _WGAvatarState();
}

class _WGAvatarState extends State<WGAvatar> {
  // Verdadeiro quando a imagem carregou com erro: mostra o fallback.
  bool _imageFailed = false;

  ImageProvider<Object>? _imageProvider() {
    final override = widget.debugImageProvider;
    if (override != null) return override;

    final url = widget.imageUrl;
    if (url == null || url.isEmpty) return null;
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    // Se não há imagem (sem URL ou falhou ao carregar), cai no fallback.
    final showFallback = _imageFailed || _imageProvider() == null;

    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: widget.borderColor != null
            ? Border.all(color: widget.borderColor!, width: widget.borderWidth)
            : null,
        boxShadow: widget.shadowColor != null
            ? [
                BoxShadow(
                  color: widget.shadowColor!,
                  blurRadius: widget.shadowBlurRadius,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: ThemeColors.primary,
        backgroundImage: showFallback ? null : _imageProvider(),
        onBackgroundImageError: showFallback
            ? null
            : (_, _) {
                // O erro pode chegar síncrono durante o paint (ex.: provider
                // que falha na hora); agendar evita setState no meio do frame.
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _imageFailed = true;
                    });
                  }
                });
              },
        child: showFallback
            ? Icon(
                Icons.person,
                color: ThemeColors.white,
                size: widget.radius * 0.9,
              )
            : null,
      ),
    );

    if (widget.onTap == null) {
      return avatar;
    }

    return GestureDetector(onTap: widget.onTap, child: avatar);
  }
}