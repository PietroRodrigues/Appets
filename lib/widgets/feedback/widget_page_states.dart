import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/buttons/widget_buttons.dart';
import 'package:appets/widgets/feedback/widget_loading.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';

/// Tela de carregamento com cabeçalho da página e indicador central.
///
/// Reutilizado nas páginas que exibem um estado de carregamento
/// inicial antes de carregar dados do servidor.
class WGPageLoading extends StatelessWidget {
  const WGPageLoading({
    super.key,
    this.title,
    this.userName,
    this.wrapInScaffold = false,
  });

  /// Título do cabeçalho (usando `WGPageHeader.title`).
  final String? title;

  /// Nome do usuário (usando `WGPageHeader.user`).
  final String? userName;

  /// Quando `true`, envolve o conteúdo em um [WGScaffold].
  final bool wrapInScaffold;

  // Monta o cabeçalho e o indicador de carregamento.
  @override
  Widget build(BuildContext context) {
    final header = userName != null
        ? WGPageHeader.user(userName: userName!, showSearchBar: false)
        : WGPageHeader.title(title: title ?? '', showSearchBar: false);

    final content = Column(
      children: [
        header,
        const Expanded(
          child: Center(child: WGLoading(color: ThemeColors.primary)),
        ),
      ],
    );

    if (!wrapInScaffold) {
      return content;
    }

    return WGScaffold(child: content);
  }
}

/// Estado vazio reutilizável com ícone, título, descrição e ação opcional.
class WGEmptyState extends StatelessWidget {
  const WGEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ÍCONE DESTACADO
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: ThemeColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: ThemeColors.primary),
            ),

            const SizedBox(height: 20),

            // TÍTULO
            Text(
              title,
              style: ThemeTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),

            // DESCRIÇÃO
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: ThemeTextStyles.body.copyWith(
                  color: ThemeColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // AÇÃO OPCIONAL
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              WGButton(
                text: actionLabel!,
                onPressed: onAction,
                width: 220,
                height: 46,
                backgroundColor: ThemeColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
