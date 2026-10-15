import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/utils/pet_filters_controller.dart';
import 'package:appets/core/utils/search_query_controller.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/feed/widget_responsive_pet_grid.dart';
import 'package:appets/widgets/feedback/widget_page_states.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:flutter/material.dart';

/// Página padronizada para telas com lista de pets (Home, Favoritos e
/// Minhas Publicações).
///
/// Agrupa cabeçalho flutuante, busca, filtros, grid responsivo com
/// pull-to-refresh e estados de carregamento/erro/vazio.
class WGFeedPage extends StatefulWidget {
  const WGFeedPage({
    super.key,
    required this.filter,
    required this.itemBuilder,
    this.headerUserName,
    this.headerTitle,
    this.headerDescription,
    this.headerHintText,
    this.showSearchBar = true,
    this.visibleTab,
    this.emptyIcon,
    this.emptyTitle,
    this.emptyDescription,
    this.emptyActionLabel,
    this.emptyAction,
    this.isLoading = false,
    this.loadError = false,
    this.errorTitle = 'Não foi possível carregar os pets',
    this.errorDescription = 'Verifique sua conexão e tente novamente.',
    this.onRetry,
    this.onRefresh,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.padding,
    this.bottomPadding = 16,
    this.topSliverPadding,
  });

  final String? headerUserName;
  final String? headerTitle;
  final String? headerDescription;
  final String? headerHintText;
  final bool showSearchBar;

  final AppPetFilter filter;
  final AppPage? visibleTab;
  final Widget Function(BuildContext context, Pet pet) itemBuilder;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry? padding;
  final double bottomPadding;
  final double? topSliverPadding;

  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptyDescription;
  final String? emptyActionLabel;
  final VoidCallback? emptyAction;

  final bool isLoading;
  final bool loadError;
  final String errorTitle;
  final String errorDescription;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;

  @override
  State<WGFeedPage> createState() => WGFeedPageState();
}

class WGFeedPageState extends State<WGFeedPage> {
  final ValueNotifier<String> _search = SearchQueryController();
  final PetFiltersController _filters = PetFiltersController();
  final GlobalKey<WGResponsivePetGridState> _gridKey = GlobalKey();
  double _headerHeight = 170;

  ValueNotifier<String> get searchNotifier => _search;

  @override
  void initState() {
    super.initState();
    AppNavigation.selectedPage.addListener(_clearSearch);
  }

  @override
  void dispose() {
    AppNavigation.selectedPage.removeListener(_clearSearch);
    _search.dispose();
    _filters.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search.value = '';
  }

  Future<void> reload() async {
    await _gridKey.currentState?.reload();
  }

  Widget _buildEmptyState() {
    final icon = widget.emptyIcon ?? Icons.pets_outlined;
    final title = widget.emptyTitle ?? 'Nenhum pet encontrado';
    final description = widget.emptyDescription ??
        'Tente ajustar seus filtros ou buscar outro termo.';
    final actionLabel = widget.emptyActionLabel;
    final action = widget.emptyAction;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: WGEmptyState(
                icon: icon,
                title: title,
                description: description,
                actionLabel: actionLabel,
                onAction: action,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topSliverPadding = widget.topSliverPadding ?? (_headerHeight + 8);

    if (widget.isLoading) {
      return Column(
        children: [
          if (widget.headerUserName != null)
            WGPageHeader.user(
              userName: widget.headerUserName!,
              showSearchBar: widget.showSearchBar,
            )
          else
            WGPageHeader.title(
              title: widget.headerTitle ?? '',
              description: widget.headerDescription,
              showSearchBar: widget.showSearchBar,
            ),
          Expanded(
            child: Center(child: const WGPetGridLoading()),
          ),
        ],
      );
    }

    if (widget.loadError) {
      return Column(
        children: [
          if (widget.headerUserName != null)
            WGPageHeader.user(
              userName: widget.headerUserName!,
              showSearchBar: widget.showSearchBar,
            )
          else
            WGPageHeader.title(
              title: widget.headerTitle ?? '',
              description: widget.headerDescription,
              showSearchBar: widget.showSearchBar,
            ),
          Expanded(
            child: WGErrorState(
              title: widget.errorTitle,
              description: widget.errorDescription,
              onAction: widget.onRetry,
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: RefreshIndicator(
            onRefresh: () async {
              if (widget.onRefresh != null) {
                await widget.onRefresh!();
              } else {
                await reload();
              }
            },
            child: ValueListenableBuilder<String>(
              valueListenable: _search,
              builder: (context, query, _) => WGResponsivePetGrid(
                key: _gridKey,
                filter: widget.filter,
                searchQuery: query,
                filterOptions: _filters,
                visibleTab: widget.visibleTab,
                topSliverPadding: topSliverPadding,
                physics: widget.physics,
                padding: widget.padding,
                bottomPadding: widget.bottomPadding,
                emptyBuilder: (context) => _buildEmptyState(),
                itemBuilder: widget.itemBuilder,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: widget.headerUserName != null
              ? WGPageHeader.user(
                  userName: widget.headerUserName!,
                  hintText: widget.headerHintText,
                  searchQuery: _search,
                  filters: _filters,
                  showSearchBar: widget.showSearchBar,
                  onHeightChanged: (height) {
                    if (mounted && height != _headerHeight) {
                      setState(() => _headerHeight = height);
                    }
                  },
                )
              : WGPageHeader.title(
                  title: widget.headerTitle ?? '',
                  description: widget.headerDescription,
                  hintText: widget.headerHintText,
                  searchQuery: _search,
                  filters: _filters,
                  showSearchBar: widget.showSearchBar,
                  onHeightChanged: (height) {
                    if (mounted && height != _headerHeight) {
                      setState(() => _headerHeight = height);
                    }
                  },
                ),
        ),
      ],
    );
  }
}
