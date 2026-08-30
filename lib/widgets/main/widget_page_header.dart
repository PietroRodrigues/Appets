import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_assets.dart';
import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Barra de busca reutilizável para as telas principais do app.
///
/// Exibe um botão de limpar (X) sempre que houver texto digitado.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onFilterPressed,
    this.showFilterButton = true,
  });

  final TextEditingController? controller;

  final String? hintText;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onFilterPressed;

  final bool showFilterButton;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  // Controller interno usado quando nenhum é fornecido externamente.
  TextEditingController? _ownController;

  // Indica se há texto para exibir o botão de limpar.
  bool _hasText = false;

  TextEditingController get _controller =>
      widget.controller ?? _ownController!;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _ownController = TextEditingController();
    }

    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.trim().isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);

      if (widget.controller == null && _ownController == null) {
        _ownController = TextEditingController();
      }

      _controller.addListener(_onTextChanged);
      _hasText = _controller.text.trim().isNotEmpty;
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;

    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  /// Limpa a busca e notifica o callback com texto vazio.
  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _ownController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Campo de Pesquisa
        Expanded(
          child: SizedBox(
            height: 48,

            child: TextField(
              controller: _controller,

              onChanged: widget.onChanged,

              decoration: InputDecoration(
                hintText: widget.hintText ?? AppStrings.searchDefaultHint,

                prefixIcon: const Icon(Icons.search),

                suffixIcon: _hasText
                    ? IconButton(
                        onPressed: _clear,
                        tooltip: AppStrings.clearSearch,
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: ThemeColors.hint,
                        ),
                      )
                    : null,

                filled: true,

                fillColor: ThemeColors.surface,

                contentPadding: const EdgeInsets.symmetric(horizontal: 16),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),

        if (widget.showFilterButton) ...[
          const SizedBox(width: 12),

          // Botão de Filtros
          SizedBox(
            width: 48,

            height: 48,

            child: Tooltip(
              message: AppStrings.filters,

              child: Material(
                color: ThemeColors.primary,

                borderRadius: BorderRadius.circular(14),

                child: InkWell(
                  borderRadius: BorderRadius.circular(14),

                  onTap: widget.onFilterPressed,

                  child: const Icon(Icons.tune, color: ThemeColors.white),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Cabeçalho reutilizável das páginas com título e campo de busca.
class AppPageHeader extends StatefulWidget {
  const AppPageHeader.user({
    super.key,
    required String this.userName,
    this.description,
    this.hintText,
    this.onSearchChanged,
    this.onFilterPressed,
    this.showSearchBar = true,
  }) : title = null;

  const AppPageHeader.title({
    super.key,
    required String this.title,
    this.description,
    this.hintText,
    this.onSearchChanged,
    this.onFilterPressed,
    this.showSearchBar = true,
  }) : userName = null;

  final String? title;
  final String? userName;
  final String? description;
  final String? hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final bool showSearchBar;

  @override
  State<AppPageHeader> createState() => _AppPageHeaderState();
}

class _AppPageHeaderState extends State<AppPageHeader> {
  static const double _logoScale = 1.3;

  bool _logoPressed = false;

  void _setLogoPressed(bool pressed) {
    if (_logoPressed == pressed) return;
    setState(() => _logoPressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ThemeColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName != null
                        ? AppStrings.helloUser(widget.userName!)
                        : widget.title!,
                    style: ThemeTextStyles.heading.copyWith(
                      color: ThemeColors.white,
                      fontSize: 24,
                    ),
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description!,
                      style: ThemeTextStyles.caption.copyWith(
                        color: ThemeColors.white,
                      ),
                    ),
                  ],
                  if (widget.showSearchBar) ...[
                    const SizedBox(height: 12),
                    AppSearchBar(
                      hintText: widget.hintText,
                      onChanged: widget.onSearchChanged,
                      onFilterPressed: widget.onFilterPressed,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: -10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _setLogoPressed(true),
                onTapUp: (_) => _setLogoPressed(false),
                onTapCancel: () => _setLogoPressed(false),
                onTap: () => AppNavigation.goHome(context),
                child: AnimatedScale(
                  scale: _logoPressed ? _logoScale : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Image.asset(
                    AppAssets.logoHeader,
                    height: 52,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}