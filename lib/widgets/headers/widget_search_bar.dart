import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

/// Barra de busca reutilizável para as telas principais do app.
///
/// Exibe um botão de limpar (X) sempre que houver texto digitado.
class WGSearchBar extends StatefulWidget {
  const WGSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSearch,
    this.onFilterPressed,
    this.searchQuery,
    this.showFilterButton = true,
  });

  final TextEditingController? controller;

  final String? hintText;

  /// Chamado a cada mudança de texto (usado só para controlar o ✕).
  final ValueChanged<String>? onChanged;

  /// Chamado quando o usuário envia a busca (botão 🔍 ou Enter).
  final ValueChanged<String>? onSearch;

  /// Quando informado, o termo buscado (e o estado limpo) é gravado aqui
  /// em vez de [onSearch]. Usado para compartilhar o estado da busca com o
  /// feed de pets das telas.
  final ValueNotifier<String>? searchQuery;

  final VoidCallback? onFilterPressed;

  final bool showFilterButton;

  @override
  State<WGSearchBar> createState() => _WGSearchBarState();
}

class _WGSearchBarState extends State<WGSearchBar> {
  // Controller interno usado quando nenhum é fornecido externamente.
  TextEditingController? _ownController;

  // Indica se há texto para exibir o botão de limpar.
  bool _hasText = false;

  TextEditingController get _controller => widget.controller ?? _ownController!;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _ownController = TextEditingController();
    }

    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.trim().isNotEmpty;
    widget.searchQuery?.addListener(_syncFromQuery);
  }

  @override
  void didUpdateWidget(covariant WGSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);

      if (widget.controller == null && _ownController == null) {
        _ownController = TextEditingController();
      }

      _controller.addListener(_onTextChanged);
      _hasText = _controller.text.trim().isNotEmpty;
    }

    if (widget.searchQuery != oldWidget.searchQuery) {
      oldWidget.searchQuery?.removeListener(_syncFromQuery);
      widget.searchQuery?.addListener(_syncFromQuery);
    }
  }

  /// Espelha no campo o estado externo do [searchQuery] (ex.: quando a
  /// troca de abas limpa a busca em outro lugar do app).
  void _syncFromQuery() {
    final query = widget.searchQuery?.value ?? '';
    if (_controller.text != query) {
      _controller.text = query;
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

  /// Limpa a busca e notifica os callbacks com texto vazio.
  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    if (widget.searchQuery != null) {
      widget.searchQuery!.value = '';
    } else {
      widget.onSearch?.call('');
    }
  }

  /// Envia o termo digitado (botão 🔍 ou Enter).
  void _submit() {
    final term = _controller.text.trim();
    if (widget.searchQuery != null) {
      widget.searchQuery!.value = term;
    } else {
      widget.onSearch?.call(term);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _ownController?.dispose();
    widget.searchQuery?.removeListener(_syncFromQuery);

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

              textInputAction: TextInputAction.search,

              onChanged: widget.onChanged,

              onSubmitted: (_) => _submit(),

              decoration: InputDecoration(
                hintText: widget.hintText ?? HomeStrings.SEARCH_DEFAULT_HINT,

                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasText)
                      IconButton(
                        onPressed: _clear,
                        tooltip: HomeStrings.CLEAR_SEARCH,
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: ThemeColors.hint,
                        ),
                      ),
                    IconButton(
                      onPressed: _submit,
                      tooltip: HomeStrings.SUBMIT_SEARCH,
                      icon: const Icon(
                        Icons.search,
                        color: ThemeColors.primary,
                      ),
                    ),
                  ],
                ),

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
              message: HomeStrings.FILTERS,

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
