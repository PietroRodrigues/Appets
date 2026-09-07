import 'package:appets/core/constants/constants_assets.dart';
import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/core/utils/pet_filters_controller.dart';
import 'package:appets/widgets/filters/widget_filter_chips_bar.dart';
import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';
import 'package:appets/widgets/headers/widget_search_bar.dart';
import 'package:flutter/material.dart';

/// Cabeçalho reutilizável das páginas com título e campo de busca.
///
/// Quando a barra de busca está ativa ([showSearchBar] = true), o próprio
/// cabeçalho cuida dos filtros: o botão de filtro abre a janela de opções e
/// os filtros aplicados são exibidos como chips logo abaixo do cabeçalho.
///
/// Se um [filters] for informado, ele é usado para a janela, os chips e a
/// limpeza na troca de aba (compartilhado com o grid); caso contrário, o
/// cabeçalho mantém seu estado interno.
class WGPageHeader extends StatefulWidget {
  const WGPageHeader.user({
    super.key,
    required String this.userName,
    this.description,
    this.hintText,
    this.onSearchChanged,
    this.onSearch,
    this.searchQuery,
    this.showSearchBar = true,
    this.onHeightChanged,
    this.filters,
  }) : title = null;

  const WGPageHeader.title({
    super.key,
    required String this.title,
    this.description,
    this.hintText,
    this.onSearchChanged,
    this.onSearch,
    this.searchQuery,
    this.showSearchBar = true,
    this.onHeightChanged,
    this.filters,
  }) : userName = null;

  final String? title;
  final String? userName;
  final String? description;
  final String? hintText;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearch;

  /// Estado compartilhado da busca (repassado à [WGSearchBar]).
  final ValueNotifier<String>? searchQuery;

  /// Estado compartilhado dos filtros (opcional).
  final PetFiltersController? filters;

  final bool showSearchBar;

  /// Notificado quando a altura total do cabeçalho muda (ex.: chips
  /// aparecem/somem). Usado pelas telas para reposicionar o conteúdo.
  final ValueChanged<double>? onHeightChanged;

  @override
  State<WGPageHeader> createState() => _WGPageHeaderState();
}

class _WGPageHeaderState extends State<WGPageHeader> {
  static const double _logoScale = 1.3;

  bool _logoPressed = false;

  /// Filtros aplicados na tela (apresentação apenas por enquanto).
  List<PetFilterOption> _activeFilters = [];

  double _lastHeight = 0;

  @override
  void initState() {
    super.initState();
    // Limpa os filtros sempre que há troca de página no menu.
    AppNavigation.selectedPage.addListener(_clearFilters);
    widget.filters?.addListener(_onFiltersChanged);
  }

  @override
  void didUpdateWidget(covariant WGPageHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      oldWidget.filters?.removeListener(_onFiltersChanged);
      widget.filters?.addListener(_onFiltersChanged);
    }
  }

  @override
  void dispose() {
    AppNavigation.selectedPage.removeListener(_clearFilters);
    widget.filters?.removeListener(_onFiltersChanged);
    super.dispose();
  }

  // Rebuilda o cabeçalho quando o controller muda para remensurar a
  // altura (chips aparecem/somem) e notificar as telas.
  void _onFiltersChanged() {
    if (mounted) setState(() {});
  }

  void _clearFilters() {
    final controller = widget.filters;
    if (controller != null) {
      if (controller.isActive) controller.clear();
      return;
    }
    if (_activeFilters.isNotEmpty && mounted) {
      setState(() => _activeFilters = []);
    }
  }

  Future<void> _openFilters() async {
    final controller = widget.filters;
    if (controller != null) {
      await controller.openDialog(context);
      return;
    }
    final options = await WGPetFiltersDialog.show(
      context,
      initialOptions: _activeFilters,
    );
    // Fechou pelo X/fora: nenhuma alteração.
    if (!mounted || options == null) return;
    setState(() => _activeFilters = options);
  }

  void _removeFilter(PetFilterOption option) {
    final controller = widget.filters;
    if (controller != null) {
      controller.remove(option);
      return;
    }
    setState(() {
      _activeFilters =
          _activeFilters.where((o) => o.id != option.id).toList();
    });
  }

  void _setLogoPressed(bool pressed) {
    if (_logoPressed == pressed) return;
    setState(() => _logoPressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final height = context.size?.height ?? 0;
      if (height > 0 && height != _lastHeight) {
        _lastHeight = height;
        widget.onHeightChanged?.call(height);
      }
    });

    final activeFilters = widget.filters?.value ?? _activeFilters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
                            ? HomeStrings.helloUser(widget.userName!)
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
                        WGSearchBar(
                          hintText: widget.hintText,
                          onChanged: widget.onSearchChanged,
                          onSearch: widget.onSearch,
                          searchQuery: widget.searchQuery,
                          onFilterPressed: _openFilters,
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
                        AppAssets.LOGO_HEADER,
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
        ),
        if (activeFilters.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: WGFilterChipsBar(
              options: activeFilters,
              onRemove: _removeFilter,
            ),
          ),
      ],
    );
  }
}