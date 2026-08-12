import 'package:flutter/material.dart';
import 'package:appets/models/enums/enum_app_page.dart';
import 'package:appets/widgets/main/widget_page_header.dart';
import 'package:appets/widgets/main/widget_pet_card.dart';
import 'package:appets/widgets/main/widget_responsive_pet_grid.dart';
import 'package:appets/models/mock_pets.dart';
import 'package:appets/screens/main/screen_favorites.dart';
import 'package:appets/screens/main/screen_publish_pet.dart';
import 'package:appets/screens/pet/screen_pet_details.dart';
import 'package:appets/widgets/common/widget_scaffold.dart';
import 'package:appets/widgets/main/widget_bottom_navigation.dart';

/// Tela inicial do app com lista de pets, busca e navegação inferior.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Aba ativa da navegação inferior.
  AppPage _currentPage = AppPage.home;

  // Atualiza a tela conforme a aba selecionada.
  void _onNavigation(AppPage page) {
    setState(() {
      _currentPage = page;
    });
  }

  // Ações da tela inicial.
  void _searchPet(String value) { // Em desenvolvimento.
    debugPrint('Buscando pet: $value');
  }

  void _onFilterPressed() { // Em desenvolvimento.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtro em desenvolvimento')),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        AppPageHeader.user(
          userName: 'Pietro',
          hintText: 'Buscar meu futuro pet',
          onSearchChanged: _searchPet, // Em desenvolvimento.
          onFilterPressed: _onFilterPressed, // Em desenvolvimento.
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {

              return ResponsivePetGrid(
                itemCount: mockPets.length, // Dados de teste.
                itemBuilder: (context, index) {
                  final pet = mockPets[index];

                  return AppPetCard(
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentPage) {
      case AppPage.home:
        return _buildHomeContent();
      case AppPage.publish:
        return const PublishPetScreen();
      case AppPage.favorites:
        return const FavoritesScreen();
      case AppPage.profile:
        return const Center(child: Text('Perfil'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: AppBottomNavigation(
        currentPage: _currentPage,
        onTap: _onNavigation,
      ),
      child: _buildBody(),
    );
  }
}
