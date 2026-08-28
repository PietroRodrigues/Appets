import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Animação de carregamento com três bolinhas pulsantes.
class AppLoading extends StatefulWidget {
  const AppLoading({
    super.key,
    this.color = ThemeColors.white,
    this.size = 10,
    this.spacing = 8,
  });

  final Color color;
  final double size;
  final double spacing;

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Inicializa o controlador da animação (loop contínuo).
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  // Libera o controlador ao sair da tela.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Calcula a opacidade de cada bolinha a partir do progresso da animação.
  double _opacity(int index) {
    final value = (_controller.value * 3 - index).abs();

    return (1 - value).clamp(0.3, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Opacity(
                opacity: _opacity(index),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
