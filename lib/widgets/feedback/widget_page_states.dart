import 'package:flutter/material.dart';

import 'package:appets/core/theme/app_colors.dart';
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
        Expanded(
          child: Center(child: WGLoading(color: context.appColors.primary)),
        ),
      ],
    );

    if (!wrapInScaffold) {
      return content;
    }

    return WGScaffold(child: content);
  }
}

/// Estado de erro reutilizável com ícone, título, descrição e ação de
/// retry opcional.
///
/// Visual herdado de [WGEmptyState], com ícone de erro por padrão.
class WGErrorState extends StatelessWidget {
  const WGErrorState({
    super.key,
    this.icon = Icons.error_outline,
    this.title = 'Não foi possível carregar os pets',
    this.description = 'Verifique sua conexão e tente novamente.',
    this.actionLabel = 'Tentar de novo',
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = onAction != null ? this.actionLabel : null;
    return WGEmptyState(
      icon: icon,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Indicador de carregamento do grid de pets: um spinner central na cor
/// primária.
///
/// As patinhas animadas ([WGLoading]) ficam nas telas de carregamento de
/// página ([WGPageLoading]) e na splash; no grid, o spinner é mais discreto e
/// não compete com os cards.
class WGPetGridLoading extends StatelessWidget {
  const WGPetGridLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.6,
        color: context.appColors.primary,
        semanticsLabel: 'Carregando',
      ),
    );
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
                color: context.appColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: context.appColors.primary),
            ),

            const SizedBox(height: 20),

            // TÍTULO
            Text(
              title,
              style: ThemeTextStyles.subtitle(context.appColors),
              textAlign: TextAlign.center,
            ),

            // DESCRIÇÃO
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: ThemeTextStyles.body(context.appColors).copyWith(
                  color: context.appColors.textSecondary,
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
                backgroundColor: context.appColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
