import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/utils/pet_filters_controller.dart';
import 'package:appets/core/utils/search_query_controller.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/screens/screen_favorites.dart';
import 'package:appets/screens/screen_my_publications.dart';
import 'package:appets/screens/screen_pet_details.dart';
import 'package:appets/screens/screen_profile.dart';
import 'package:appets/screens/screen_publish_pet.dart';
import 'package:appets/widgets/feed/widget_pet_card.dart';
import 'package:appets/widgets/feed/widget_responsive_pet_grid.dart';
import 'package:appets/widgets/feedback/widget_page_states.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:appets/widgets/navigation/widget_bottom_navigation.dart';
import 'package:flutter/material.dart';

/// Tela inicial do app com lista de pets, busca e navegação inferior.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  bool _isLoading = true;
  final ValueNotifier<String> _search = SearchQueryController();
  final PetFiltersController _filters = PetFiltersController();
  final GlobalKey<WGResponsivePetGridState> _gridKey = GlobalKey();

  /// Altura do cabeçalho flutuante; usada para posicionar o grid por trás.
  double _headerHeight = 170;

  @override
  void initState() {
    super.initState();
    AppNavigation.selectedPage.value = AppPage.home;
    AppNavigation.selectedPage.addListener(_clearSearch);
    _loadData();
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

  Future<void> _loadData() async {
    final authUser = AuthService.instance.currentUser;
    if (authUser != null) {
      _user = await FirestoreService.instance.getUser(authUser.uid);
      await FavoritesService.instance.loadForUser(authUser.uid);
      await MyPublicationsService.instance.loadForUser(authUser.uid);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavigation(AppPage page) {
    AppNavigation.selectedPage.value = page;
  }

  Future<void> _openPublishPet() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const PublishPetScreen()),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return WGPageLoading(
        userName: _user?.name ?? HomeStrings.DEFAULT_USER_NAME,
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadData();
              await _gridKey.currentState?.reload();
            },
            child: ValueListenableBuilder<String>(
              valueListenable: _search,
              builder: (context, query, _) => WGResponsivePetGrid(
                key: _gridKey,
                filter: AppPetFilter.all,
                searchQuery: query,
                filterOptions: _filters,
                topSliverPadding: _headerHeight + 8,
                physics: const AlwaysScrollableScrollPhysics(),
                emptyBuilder: (context) => _refreshableEmptyState(
                  icon: Icons.pets_outlined,
                  title: HomeStrings.EMPTY_PETS_TITLE,
                  description: HomeStrings.EMPTY_PETS_DESCRIPTION,
                  actionLabel: HomeStrings.EMPTY_PETS_ACTION,
                  onAction: _openPublishPet,
                ),
                itemBuilder: (context, pet) {
                  return WGPetCard(
                    pet: pet,
                    heroTag: 'pet-image-${pet.id}',
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
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: WGPageHeader.user(
            userName: _user?.name ?? HomeStrings.DEFAULT_USER_NAME,
            hintText: HomeStrings.SEARCH_DEFAULT_HINT,
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

  Widget _refreshableEmptyState({
    required IconData icon,
    required String title,
    required String description,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
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
                onAction: onAction,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(AppPage currentPage) {
    return IndexedStack(
      index: currentPage.index,
      children: [
        _buildHomeContent(),
        FavoritesScreen(onExplore: () => _onNavigation(AppPage.home)),
        MyPublicationsScreen(onPublish: _openPublishPet),
        const ProfileScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppPage>(
      valueListenable: AppNavigation.selectedPage,
      builder: (context, currentPage, _) {
        final showFab = currentPage == AppPage.myPublications;

        return WGScaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: WGBottomNavigation(
            currentPage: currentPage,
            onTap: _onNavigation,
          ),
          floatingActionButton: showFab
              ? FloatingActionButton(
                  onPressed: _openPublishPet,
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: ThemeColors.white,
                  elevation: 8,
                  child: const Icon(Icons.add, size: 32),
                )
              : null,
          child: _buildBody(currentPage),
        );
      },
    );
  }
}