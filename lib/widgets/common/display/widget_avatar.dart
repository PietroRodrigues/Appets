import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Avatar circular do usuário, com imagem opcional e ação ao tocar.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.onTap,
    this.radius = 50,
    this.borderColor,
    this.borderWidth = 3,
    this.shadowColor,
    this.shadowBlurRadius = 8,
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

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: shadowColor != null
            ? [
                BoxShadow(
                  color: shadowColor!,
                  blurRadius: shadowBlurRadius,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: ThemeColors.primary,
        backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
            ? NetworkImage(imageUrl!)
            : null,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(
                Icons.person,
                color: ThemeColors.white,
                size: radius * 0.9,
              )
            : null,
      ),
    );

    if (onTap == null) {
      return avatar;
    }

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}
