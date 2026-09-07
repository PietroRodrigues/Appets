import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/utils/pet_filters_controller.dart';
import 'package:appets/core/utils/search_query_controller.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/screens/screen_pet_details.dart';
import 'package:appets/widgets/feed/widget_pet_card.dart';
import 'package:appets/widgets/feed/widget_responsive_pet_grid.dart';
import 'package:appets/widgets/feedback/widget_page_states.dart';
import 'package:appets/widgets/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:flutter/material.dart';

/// Tela que exibe as publicações de pets feitas pelo usuário.
///
/// Filtra apenas os pets cujo [Pet.ownerId] corresponde ao
/// usuário logado. Exibe botão de edição nos cards.
class MyPublicationsScreen extends StatefulWidget {
  const MyPublicationsScreen({super.key, this.onPublish});

  /// Ação do CTA do estado vazio (abre a tela de publicar pet).
  final VoidCallback? onPublish;

  @override
  State<MyPublicationsScreen> createState() => _MyPublicationsScreenState();
}

class _MyPublicationsScreenState extends State<MyPublicationsScreen> {
  final ValueNotifier<String> _search = SearchQueryController();
  final PetFiltersController _filters = PetFiltersController();
  final GlobalKey<WGResponsivePetGridState> _gridKey = GlobalKey();

  /// Altura do cabeçalho flutuante; usada para posicionar o grid por trás.
  double _headerHeight = 170;

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

  // Limpa a busca da aba sempre que há troca de página no menu.
  void _clearSearch() {
    _search.value = '';
  }

  void _editPet(Pet pet) {
    WGSnackBar.show(context, HomeStrings.editingPet(pet.name));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RefreshIndicator(
            onRefresh: () async {
              await _gridKey.currentState?.reload();
            },
            child: ValueListenableBuilder<String>(
              valueListenable: _search,
              builder: (context, query, _) => WGResponsivePetGrid(
                key: _gridKey,
                filter: AppPetFilter.myPublications,
                searchQuery: query,
                filterOptions: _filters,
                topSliverPadding: _headerHeight + 8,
                physics: const AlwaysScrollableScrollPhysics(),
                emptyBuilder: (context) => _refreshableEmptyState(),
                itemBuilder: (context, pet) {
                  return WGPetCard(
                    pet: pet,
                    isMyPublication: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetDetailsScreen(pet: pet),
                        ),
                      );
                    },
                    onEdit: () => _editPet(pet),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: WGPageHeader.title(
            title: HomeStrings.MY_PUBLICATIONS_TITLE,
            description: HomeStrings.MY_PUBLICATIONS_DESCRIPTION,
            hintText: HomeStrings.PUBLICATIONS_SEARCH_HINT,
            searchQuery: _search,
            filters: _filters,
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

  Widget _refreshableEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: WGEmptyState(
                icon: Icons.pets_outlined,
                title: HomeStrings.EMPTY_PUBLICATIONS_TITLE,
                description: HomeStrings.EMPTY_PUBLICATIONS_DESCRIPTION,
                actionLabel: widget.onPublish != null
                    ? HomeStrings.PUBLISH_PET
                    : null,
                onAction: widget.onPublish,
              ),
            ),
          ),
        );
      },
    );
  }
}