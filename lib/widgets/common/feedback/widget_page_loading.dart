import 'package:flutter/material.dart';

import 'package:appets/widgets/common/layout/widget_scaffold.dart';
import 'package:appets/widgets/main/widget_page_header.dart';

/// Tela de carregamento com cabeçalho da página e indicador central.
///
/// Reutilizado nas páginas que exibem um estado de carregamento
/// inicial antes de carregar dados do servidor.
class AppPageLoading extends StatelessWidget {
  const AppPageLoading({
    super.key,
    this.title,
    this.userName,
    this.wrapInScaffold = false,
  });

  /// Título do cabeçalho (usando `AppPageHeader.title`).
  final String? title;

  /// Nome do usuário (usando `AppPageHeader.user`).
  final String? userName;

  /// Quando `true`, envolve o conteúdo em um [AppScaffold].
  final bool wrapInScaffold;

  // Monta o cabeçalho e o indicador de carregamento.
  @override
  Widget build(BuildContext context) {
    final header = userName != null
        ? AppPageHeader.user(
            userName: userName!,
            showSearchBar: false,
          )
        : AppPageHeader.title(
            title: title ?? '',
            showSearchBar: false,
          );

    final content = Column(
      children: [
        header,
        const Expanded(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );

    if (!wrapInScaffold) {
      return content;
    }

    return AppScaffold(child: content);
  }
}
