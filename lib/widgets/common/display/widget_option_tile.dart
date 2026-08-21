import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

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
                        color: ThemeColors.textPrimary,
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
