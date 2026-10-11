import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/screens/screen_favorites.dart';
import 'package:appets/screens/screen_my_publications.dart';
import 'package:appets/screens/screen_pet_details.dart';
import 'package:appets/screens/screen_profile.dart';
import 'package:appets/screens/screen_publish_pet.dart';
import 'package:appets/widgets/feed/widget_feed_page.dart';
import 'package:appets/widgets/feed/widget_pet_card.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:appets/widgets/layout/widget_root_back_exit.dart';
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
  bool _loadError = false;
  final GlobalKey<WGFeedPageState> _feedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    AppNavigation.selectedPage.value = AppPage.home;
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser != null) {
        // Leitura única do documento do usuário: o mesmo model alimenta o
        // header da Home e os serviços de favoritos/publicações das abas.
        _user = await FirestoreService.instance.getUser(authUser.uid);
        FavoritesService.instance.applyUser(_user);
        await MyPublicationsService.instance.applyUser(_user);
      }
      if (mounted) {
        setState(() => _loadError = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Reexecuta a carga inicial após uma falha (botão "Tentar de novo").
  void _retryLoad() {
    setState(() {
      _isLoading = true;
      _loadError = false;
    });
    _loadData();
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
    return WGFeedPage(
      key: _feedKey,
      filter: AppPetFilter.all,
      headerUserName: _user?.name ?? HomeStrings.DEFAULT_USER_NAME,
      headerHintText: HomeStrings.SEARCH_DEFAULT_HINT,
      visibleTab: AppPage.home,
      isLoading: _isLoading,
      loadError: _loadError,
      errorTitle: SharedStrings.LOAD_DATA_ERROR_TITLE,
      errorDescription: SharedStrings.LOAD_DATA_ERROR_DESCRIPTION,
      onRetry: _retryLoad,
      onRefresh: () async {
        await _loadData();
        await _feedKey.currentState?.reload();
      },
      emptyIcon: Icons.pets_outlined,
      emptyTitle: HomeStrings.EMPTY_PETS_TITLE,
      emptyDescription: HomeStrings.EMPTY_PETS_DESCRIPTION,
      emptyActionLabel: HomeStrings.EMPTY_PETS_ACTION,
      emptyAction: _openPublishPet,
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

        return WGRootBackExit(
          child: WGScaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: WGBottomNavigation(
              currentPage: currentPage,
              onTap: _onNavigation,
            ),
            floatingActionButton: showFab
                ? FloatingActionButton(
                    onPressed: _openPublishPet,
                    backgroundColor: context.appColors.primary,
                    foregroundColor: context.appColors.onPrimary,
                    elevation: 8,
                    child: const Icon(Icons.add, size: 32),
                  )
                : null,
            child: _buildBody(currentPage),
          ),
        );
      },
    );
  }
}
