import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_assets.dart';

/// Logo institucional do APPets.
class WGLogo extends StatelessWidget {
  const WGLogo({super.key, this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // O logo é decorativo; o rótulo identifica o app para leitores de tela.
      label: 'APPets',
      image: true,
      child: ExcludeSemantics(
        child: Image.asset(
          AppAssets.LOGO,
          width: width,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
