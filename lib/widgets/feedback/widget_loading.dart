import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Indicador de carregamento com quatro patinhas em zigue-zague que pulsam a
/// opacidade em sequência, como as antigas bolinhas de loading.
///
/// As patas ficam fixas (0 desce, 1 sobe, 2 desce, 3 sobe), giradas para a
/// direita, e apenas o alfa percorre a fileira da esquerda para a direita. É o
/// indicador padrão do app: usado na splash, no carregamento de página e na
/// tela de processo (o grid de pets usa um spinner próprio).
class WGLoading extends StatefulWidget {
  const WGLoading({
    super.key,
    this.color = Colors.white,
    this.size = 15,
    this.spacing = 0.5,
    this.pawCount = 4,
  });

  final Color color;

  /// Tamanho de cada pata.
  final double size;

  /// Espaço entre as patas (bem pequeno: elas ficam quase encostadas).
  final double spacing;

  /// Quantidade de patinhas exibidas.
  final int pawCount;

  @override
  State<WGLoading> createState() => _WGLoadingState();
}

class _WGLoadingState extends State<WGLoading>
    with SingleTickerProviderStateMixin {
  // Inclinação lateral das patas (ímpares para a direita, pares para a
  // esquerda), somada à rotação base de 90°.
  static const _tilt = 20 * math.pi / 180;

  late final AnimationController _controller;

  // Inicializa o controlador da animação (loop contínuo).
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
  }

  // Libera o controlador ao sair da tela.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Opacidade de cada pata: a "onda" percorre a fileira da esquerda para a
  // direita (mesma mecânica das antigas bolinhas de loading).
  double _opacity(int index) {
    final distance = (_controller.value * widget.pawCount - index).abs();

    return (1 - distance).clamp(0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // Zigue-zague de um "caminhar": metade das patas desce, a outra sobe.
    final lift = widget.size * 0.6;
    final height = widget.size + lift * 6;

    return Semantics(
      // Anuncia o carregamento para leitores de tela quando ele aparece.
      label: 'Carregando',
      liveRegion: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return SizedBox(
            // Reserva a altura do zigue-zague para as patas não cortarem.
            height: height,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.pawCount, (index) {
                // Patas ímpares sobem; pares descem: aparenta caminhada.
                final up = index.isOdd;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.spacing / 2,
                  ),
                  child: Transform.translate(
                    offset: Offset(0, up ? -lift : lift),
                    child: Opacity(
                      opacity: _opacity(index),
                      child: RotatedBox(
                        // Deitada para a direita: aponta para onde "anda".
                        quarterTurns: 1,
                        child: Transform.rotate(
                          // As patas apontam para o lado oposto à posição: as
                          // de baixo (pares) inclinam para baixo; as de cima
                          // (ímpares), para cima.
                          angle: up ? -_tilt : _tilt,
                          child: Icon(
                            Icons.pets,
                            size: widget.size,
                            color: widget.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
