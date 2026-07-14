import 'package:flutter/material.dart';

import 'package:appets/core/theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget body = child;

    if (padding != null) {
      body = Padding(
        padding: padding!,
        child: body,
      );
    }

    if (useSafeArea) {
      body = SafeArea(
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: body,
    );
  }
}