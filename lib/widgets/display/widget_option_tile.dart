import 'package:flutter/material.dart';

import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Tile de opção reutilizável com ícone, título e subtítulo opcional.
///
/// Usado nas telas de perfil, configurações e dados da conta.
///
/// Com [filled] (padrão), o tile ganha fundo em [AppColors.surface]
/// e uma seta à direita (estilo das listas de configurações).
/// Sem [filled], fica centralizado e sem fundo
/// (estilo das opções da tela de perfil).
///
/// Com [isDestructive], ícone e título usam a cor de erro
/// (estilo da opção "Desconectar").
///
/// Com [enabled] `false`, o tile fica visível porém bloqueado:
/// ícone, título, subtítulo e seta ficam acinzentados
/// ([AppColors.disabled]) e o toque não dispara [onTap].
class WGOptionTile extends StatelessWidget {
  const WGOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
    this.filled = true,
    this.enabled = true,
  });

  // PROPERTIES
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  /// Texto exibido abaixo do título.
  final String? subtitle;
  final bool isDestructive;
  final bool filled;

  /// Quando `false`, o tile aparece visível porém bloqueado.
  final bool enabled;

  // UI
  Color _accentColor(AppColors colors) {
    return isDestructive ? colors.error : colors.primary;
  }

  Color _iconColor(AppColors colors) =>
      enabled ? _accentColor(colors) : colors.disabled;

  Color _titleColor(AppColors colors) {
    if (!enabled) return colors.disabled;
    return isDestructive ? colors.error : colors.textPrimary;
  }

  Widget _buildIcon(AppColors colors) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _iconColor(colors).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: _iconColor(colors)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!filled) {
      return Center(
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ÍCONE
                _buildIcon(context.appColors),

                const SizedBox(width: 14),

                // TÍTULO
                Text(
                  title,
                  style: ThemeTextStyles.subtitle(context.appColors)
                      .copyWith(color: _titleColor(context.appColors)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // ÍCONE
              _buildIcon(context.appColors),

              const SizedBox(width: 14),

              // TEXTOS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeTextStyles.subtitle(context.appColors)
                          .copyWith(color: _titleColor(context.appColors)),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: ThemeTextStyles.caption(context.appColors)
                            .copyWith(
                              color: enabled
                                  ? null
                                  : context.appColors.disabled,
                            ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // SETA
              Icon(
                Icons.chevron_right_outlined,
                color: enabled
                    ? context.appColors.hint
                    : context.appColors.disabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
