import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

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

/// Linha de informação reutilizável com ícone e texto.
///
/// Usada na tela de detalhes do pet para exibir
/// idade, gênero, cidade e tipo de publicação.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = ThemeColors.secondary,
    this.textStyle,
  });

  // PROPERTIES
  final IconData icon;
  final String text;

  /// Cor do ícone (padrão: secundária).
  final Color iconColor;

  /// Estilo do texto (padrão: [ThemeTextStyles.body]).
  final TextStyle? textStyle;

  // UI
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
        ),

        const SizedBox(width: 8),

        Text(
          text,
          style: textStyle ?? ThemeTextStyles.body,
        ),
      ],
    );
  }
}

/// Tile de opção reutilizável com ícone, título e subtítulo opcional.
///
/// Usado nas telas de perfil, configurações e dados da conta.
///
/// Com [filled] (padrão), o tile ganha fundo em [ThemeColors.surface]
/// e uma seta à direita (estilo das listas de configurações).
/// Sem [filled], fica centralizado e sem fundo
/// (estilo das opções da tela de perfil).
///
/// Com [isDestructive], ícone e título usam a cor de erro
/// (estilo da opção "Desconectar").
class AppOptionTile extends StatelessWidget {
  const AppOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
    this.filled = true,
  });

  // PROPERTIES
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  /// Texto exibido abaixo do título.
  final String? subtitle;
  final bool isDestructive;
  final bool filled;

  // UI
  Color get _accentColor {
    return isDestructive ? ThemeColors.error : ThemeColors.primary;
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: _accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!filled) {
      return Center(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ÍCONE
                _buildIcon(),

                const SizedBox(width: 14),

                // TÍTULO
                Text(
                  title,
                  style: ThemeTextStyles.subtitle.copyWith(
                    color: isDestructive
                        ? ThemeColors.error
                        : ThemeColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              // ÍCONE
              _buildIcon(),

              const SizedBox(width: 14),

              // TEXTOS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeTextStyles.subtitle.copyWith(
                        color: isDestructive
                            ? ThemeColors.error
                            : ThemeColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: ThemeTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // SETA
              const Icon(
                Icons.chevron_right_outlined,
                color: ThemeColors.hint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Imagem de um pet que aceita tanto URLs remotas (Firebase Storage)
/// quanto caminhos de assets locais.
///
/// Permite que os dados reais (URLs de armazenamento) sejam exibidos
/// da mesma forma que os assets usados durante o desenvolvimento.
class AppPetImage extends StatelessWidget {
  const AppPetImage({
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
      return const _AppPetImagePlaceholder();
    }

    if (_isNetwork) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, _, _) => const _AppPetImagePlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _AppPetImagePlaceholder(showIndicator: true);
        },
      );
    }

    return Image.asset(url, fit: fit);
  }
}

/// Placeholder exibido quando uma imagem de pet não está disponível.
class _AppPetImagePlaceholder extends StatelessWidget {
  const _AppPetImagePlaceholder({this.showIndicator = false});

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