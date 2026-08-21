import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/enums/enum_app_page.dart';

/// Barra de navegação inferior com ícones e rótulos centralizados.
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
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: ThemeColors.primary,
          borderRadius: BorderRadius.circular(28),
          elevation: 12,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavIconButton(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Início',
                  isActive: currentPage == AppPage.home,
                  onTap: () => onTap(AppPage.home),
                ),
                _NavIconButton(
                  icon: Icons.star_border,
                  activeIcon: Icons.star,
                  label: 'Favoritos',
                  isActive: currentPage == AppPage.favorites,
                  onTap: () => onTap(AppPage.favorites),
                ),
                _NavIconButton(
                  icon: Icons.campaign_outlined,
                  activeIcon: Icons.campaign,
                  label: 'Publicações',
                  isActive: currentPage == AppPage.myPublications,
                  onTap: () => onTap(AppPage.myPublications),
                ),
                _NavIconButton(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Perfil',
                  isActive: currentPage == AppPage.profile,
                  onTap: () => onTap(AppPage.profile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// Item de navegação com ícone, rótulo e efeito ripple.
class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isActive
        ? ThemeColors.navigationActive
        : ThemeColors.navigationInactive;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 28,
                color: itemColor,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: ThemeTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: itemColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
