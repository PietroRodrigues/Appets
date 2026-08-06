import 'package:appets/model/enums/app_pet_gender.dart';
import 'package:flutter/material.dart';

import 'package:appets/model/enums/app_page.dart';
import 'package:appets/widgets/home/app_bottom_navigation.dart';
import 'package:appets/widgets/home/app_home_header.dart';
import 'package:appets/widgets/home/app_pet_card.dart';
import 'package:appets/widgets/common/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //══════════════════════════════════════════════════════════════
  // STATE
  //
  // Variáveis responsáveis por atualizar a interface.
  // Enquanto não utilizamos Firebase, trabalharemos com
  // dados temporários apenas para montar a tela.
  //══════════════════════════════════════════════════════════════

  AppPage _currentPage = AppPage.home;

  final List<String> _pets = [

    'Thor',

    'Luna',

    'Mel',

    'Bob',

    'Nina',

    'Max',

    'Luke',

    'Fred',

  ];


  //══════════════════════════════════════════════════════════════
  // NAVIGATION
  //
  // Toda navegação inferior ficará concentrada aqui.
  //══════════════════════════════════════════════════════════════

  void _onNavigation(AppPage page) {

    setState(() {

      _currentPage = page;

    });

    switch (page) {

      case AppPage.home:

        break;

      case AppPage.publish:

        // TODO:
        // Navegar para PublishPetScreen.

        break;

      case AppPage.favorites:

        // TODO:
        // Navegar para FavoritesScreen.

        break;

    }

  }


  //══════════════════════════════════════════════════════════════
  // ACTIONS
  //
  // Ações da tela.
  //══════════════════════════════════════════════════════════════

  void _openProfile() {

    // TODO:
    // Abrir perfil.

  }

  void _searchPet(String value) {

    // TODO:
    // Implementar pesquisa futuramente.

  }


  //══════════════════════════════════════════════════════════════
  // UI
  //══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return AppScaffold(

      bottomNavigationBar: AppBottomNavigation(

        currentPage: _currentPage,

        onTap: _onNavigation,

      ),

      child: Column(

        children: [

          //------------------------------------------------------
          // Cabeçalho
          //------------------------------------------------------

          AppHomeHeader(

            userName: 'Pietro',

            onProfileTap: _openProfile,

            onSearchChanged: _searchPet,

          ),

          //------------------------------------------------------
          // Lista de Pets
          //------------------------------------------------------

          Expanded(

            child: Padding(

              padding: const EdgeInsets.all(20),

              child: GridView.builder(

                itemCount: _pets.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount: 2,

                  crossAxisSpacing: 16,

                  mainAxisSpacing: 16,

                  childAspectRatio: .72,

                ),

                itemBuilder: (context, index) {

                  return AppPetCard(

                    //================================================
                    // Dados temporários
                    //================================================

                    imagePath: 'assets/images/dog.png',
                    name: _pets[index],
                    age: 2,
                    gender: AppPetGender.male,
                    city: 'São Paulo',

                    onTap: () {

                      // TODO:
                      // Abrir detalhes do Pet.

                    },

                  );

                },

              ),
            ),
          ),

        ],

      ),

    );

  }

}