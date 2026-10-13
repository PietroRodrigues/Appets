import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/screens/screen_pet_details.dart';
import 'package:appets/widgets/feed/widget_feed_page.dart';
import 'package:appets/widgets/feed/widget_pet_card.dart';
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
  final GlobalKey<WGFeedPageState> _feedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    AppNavigation.selectedPage.addListener(_clearSearch);
  }

  @override
  void dispose() {
    AppNavigation.selectedPage.removeListener(_clearSearch);
    super.dispose();
  }

  void _clearSearch() {
    _feedKey.currentState?.searchNotifier.value = '';
  }

  @override
  Widget build(BuildContext context) {
    return WGFeedPage(
      key: _feedKey,
      filter: AppPetFilter.favorites,
      visibleTab: AppPage.favorites,
      headerTitle: HomeStrings.FAVORITES_TITLE,
      headerHintText: HomeStrings.FAVORITES_SEARCH_HINT,
      emptyIcon: Icons.star_border_rounded,
      emptyTitle: HomeStrings.EMPTY_FAVORITES_TITLE,
      emptyDescription: HomeStrings.EMPTY_FAVORITES_DESCRIPTION,
      emptyActionLabel: widget.onExplore != null
          ? HomeStrings.EXPLORE_PETS
          : null,
      emptyAction: widget.onExplore,
      itemBuilder: (context, pet) {
        return WGPetCard(
          pet: pet,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PetDetailsScreen(pet: pet),
              ),
            );
          },
        );
      },
    );
  }
}