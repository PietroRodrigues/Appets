import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enum_app_page.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentPage,
    required this.onTap,
  });

  final AppPage currentPage;
  final ValueChanged<AppPage> onTap;

  @override
  Widget build(BuildContext context) {
    const pages = [
      AppPage.home,
      AppPage.favorites,
      AppPage.publish,
      AppPage.profile,
    ];

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home, size: 35),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.favorite_border, size: 24),
        selectedIcon: Icon(Icons.favorite, size: 35),
        label: 'Favoritos',
      ),
      const NavigationDestination(
        icon: Icon(Icons.add_circle_outline, size: 24),
        selectedIcon: Icon(Icons.add_circle, size: 35),
        label: 'Publicar',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline, size: 24),
        selectedIcon: Icon(Icons.person, size: 35),
        label: 'Perfil',
      ),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28),
          elevation: 12,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(color: Colors.white);
                  }
                  return const IconThemeData(color: AppColors.navigationInactive);
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    );
                  }
                  return const TextStyle(
                    color: AppColors.navigationInactive,
                    fontWeight: FontWeight.normal,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: pages.indexOf(currentPage),
                onDestinationSelected: (index) {
                  onTap(pages[index]);
                },
                backgroundColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                indicatorColor: Colors.transparent,
                destinations: destinations,
                height: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
