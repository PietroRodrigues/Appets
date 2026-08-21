import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Scaffold base com estilo visual e opções comuns do projeto.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    Widget body = child;

    if (padding != null) {
      body = Padding(padding: padding!, child: body);
    }

    if (useSafeArea) {
      body = SafeArea(child: body);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? ThemeColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
