import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';

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
                hintText: widget.hintText ?? 'Buscar meu futuro pet',

                prefixIcon: const Icon(Icons.search),

                suffixIcon: _hasText
                    ? IconButton(
                        onPressed: _clear,
                        tooltip: 'Limpar busca',
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
              message: 'Filtros',

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
