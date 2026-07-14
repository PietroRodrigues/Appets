import 'package:flutter/material.dart';

import 'package:appets/core/constants/app_assets.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 220,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      width: width,
      fit: BoxFit.contain,
    );
  }
}