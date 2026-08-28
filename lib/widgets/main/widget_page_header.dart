import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_assets.dart';
import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/main/widget_search_bar.dart';

/// Cabeçalho reutilizável das páginas com título e campo de busca.
class AppPageHeader extends StatefulWidget {
  const AppPageHeader.user({
    super.key,
    required String this.userName,
    this.description,
    this.hintText,
    this.onSearchChanged,
    this.onFilterPressed,
    this.showSearchBar = true,
  }) : title = null;

  const AppPageHeader.title({
    super.key,
    required String this.title,
    this.description,
    this.hintText,
    this.onSearchChanged,
    this.onFilterPressed,
    this.showSearchBar = true,
  }) : userName = null;

  final String? title;
  final String? userName;
  final String? description;
  final String? hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final bool showSearchBar;

  @override
  State<AppPageHeader> createState() => _AppPageHeaderState();
}

class _AppPageHeaderState extends State<AppPageHeader> {
  static const double _logoScale = 1.3;

  bool _logoPressed = false;

  void _setLogoPressed(bool pressed) {
    if (_logoPressed == pressed) return;
    setState(() => _logoPressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ThemeColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName != null
                        ? AppStrings.helloUser(widget.userName!)
                        : widget.title!,
                    style: ThemeTextStyles.heading.copyWith(
                      color: ThemeColors.white,
                      fontSize: 24,
                    ),
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description!,
                      style: ThemeTextStyles.caption.copyWith(
                        color: ThemeColors.white,
                      ),
                    ),
                  ],
                  if (widget.showSearchBar) ...[
                    const SizedBox(height: 12),
                    AppSearchBar(
                      hintText: widget.hintText,
                      onChanged: widget.onSearchChanged,
                      onFilterPressed: widget.onFilterPressed,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: -10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _setLogoPressed(true),
                onTapUp: (_) => _setLogoPressed(false),
                onTapCancel: () => _setLogoPressed(false),
                onTap: () => AppNavigation.goHome(context),
                child: AnimatedScale(
                  scale: _logoPressed ? _logoScale : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Image.asset(
                    AppAssets.logoHeader,
                    height: 52,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

