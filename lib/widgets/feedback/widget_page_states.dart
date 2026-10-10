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

//// Bloco placeholder retangular usado nos esqueletos de carregamento.
///
/// Cor neutra ([ThemeColors.divider]) que se sobressai discretamente sobre
/// o fundo creme; a "piscada" fica por conta da animação de pulso em
/// [WGSkeletonPetGrid].
class WGSkeletonBox extends StatelessWidget {
  const WGSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ThemeColors.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Card placeholder que imita o layout real do [WGPetCard] enquanto a lista
/// ainda carrega: área de imagem em ~54% da altura, linhas de texto (título e
/// espécie), "ícones" de idade/gênero e o chip do tipo de publicação.
class WGSkeletonPetCard extends StatelessWidget {
  const WGSkeletonPetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: ThemeColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = constraints.maxHeight * 0.54;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ÁREA DA IMAGEM (full-bleed, como o card real)
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: const WGSkeletonBox(borderRadius: 0),
              ),
              // INFORMAÇÕES
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    const WGSkeletonBox(width: 140, height: 16),
                    const SizedBox(height: 8),
                    // Espécie · raça
                    const WGSkeletonBox(width: 92, height: 12),
                    const SizedBox(height: 12),
                    // Idade + gênero
                    Row(
                      children: const [
                        WGSkeletonBox(width: 12, height: 12, borderRadius: 6),
                        SizedBox(width: 8),
                        WGSkeletonBox(width: 36, height: 12),
                        SizedBox(width: 12),
                        WGSkeletonBox(width: 16, height: 16, borderRadius: 8),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Chip do tipo de publicação
                    const WGSkeletonBox(width: 64, height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Grade de cards-esqueleto "piscando" exibida durante o carregamento inicial
/// do grid de pets (substitui o spinner central).
///
/// Repete as mesmas regras de layout do grid real (1/2/3 colunas conforme a
/// largura, mesmos paddings/aspect ratios/espaçamentos) com uma animação de
/// pulso de opacidade. Respeita `MediaQuery.disableAnimations`: sem
/// acessibilidade reduzida o pulso roda em loop; com a opção ativa, a grade
/// fica estática (sem ticker).
class WGSkeletonPetGrid extends StatefulWidget {
  const WGSkeletonPetGrid({super.key, this.itemCount = 6});

  /// Quantidade total de cards placeholder exibidos.
  final int itemCount;

  @override
  State<WGSkeletonPetGrid> createState() => _WGSkeletonPetGridState();
}

class _WGSkeletonPetGridState extends State<WGSkeletonPetGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  // Inicia o pulso no primeiro build (o ticker só existe quando a opacidade
  // realmente anima; com animações reduzidas, fica no valor fixo).
  void _ensureAnimation() {
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1.0;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureAnimation();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 320
            ? 1
            : width < 700
            ? 2
            : 3;
        final childAspectRatio = width < 320
            ? 0.84
            : width < 700
            ? 0.68
            : 0.74;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width < 320 ? 10 : 14,
            vertical: width < 320 ? 10 : 16,
          ),
          child: FadeTransition(
            opacity: _pulse,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: width < 320 ? 8 : 12,
              mainAxisSpacing: width < 320 ? 8 : 12,
              childAspectRatio: childAspectRatio,
              children: List.generate(
                widget.itemCount,
                (_) => const WGSkeletonPetCard(),
              ),
            ),
          ),
        );
      },
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
                color: ThemeColors.primarySoft,
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
