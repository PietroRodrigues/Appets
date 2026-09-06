import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/utils/search_query_controller.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/screens/screen_pet_details.dart';
import 'package:appets/widgets/feed/widget_pet_card.dart';
import 'package:appets/widgets/feed/widget_responsive_pet_grid.dart';
import 'package:appets/widgets/feedback/widget_page_states.dart';
import 'package:appets/widgets/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:flutter/material.dart';

/// Tela que reúne os pets favoritos do usuário.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, this.onExplore});

  /// Ação do CTA do estado vazio (volta para a aba inicial).
  final VoidCallback? onExplore;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ValueNotifier<String> _search = SearchQueryController();
  final GlobalKey<WGResponsivePetGridState> _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    AppNavigation.selectedPage.addListener(_clearSearch);
  }

  @override
  void dispose() {
    AppNavigation.selectedPage.removeListener(_clearSearch);
    _search.dispose();
    super.dispose();
  }

  // Limpa a busca da aba sempre que há troca de página no menu.
  void _clearSearch() {
    _search.value = '';
  }

  void _onFilterPressed() {
    WGSnackBar.development(context, HomeStrings.FILTERS);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WGPageHeader.title(
          title: HomeStrings.FAVORITES_TITLE,
          hintText: HomeStrings.FAVORITES_SEARCH_HINT,
          searchQuery: _search,
          onFilterPressed: _onFilterPressed,
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _gridKey.currentState?.reload();
            },
            child: ValueListenableBuilder<String>(
              valueListenable: _search,
              builder: (context, query, _) => WGResponsivePetGrid(
                key: _gridKey,
                filter: AppPetFilter.favorites,
                searchQuery: query,
                physics: const AlwaysScrollableScrollPhysics(),
                emptyBuilder: (context) => _refreshableEmptyState(),
                itemBuilder: (context, pet) {
                  return WGPetCard(
                    pet: pet,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetDetailsScreen(pet: pet),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _refreshableEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: WGEmptyState(
                icon: Icons.star_border_rounded,
                title: HomeStrings.EMPTY_FAVORITES_TITLE,
                description: HomeStrings.EMPTY_FAVORITES_DESCRIPTION,
                actionLabel: widget.onExplore != null
                    ? HomeStrings.EXPLORE_PETS
                    : null,
                onAction: widget.onExplore,
              ),
            ),
          ),
        );
      },
    );
  }
}
