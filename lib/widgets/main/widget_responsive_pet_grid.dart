import 'package:flutter/material.dart';

/// Grid responsivo para listas de pets.
///
/// Ajusta o número de colunas conforme a largura disponível.
class AppResponsivePetGrid extends StatelessWidget {
  const AppResponsivePetGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.bottomPadding = 120,
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double bottomPadding;

  /// Física de rolagem do grid. Use `AlwaysScrollableScrollPhysics`
  /// quando envolvido por um [RefreshIndicator] para permitir o
  /// pull-to-refresh mesmo com poucos itens.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 320 ? 1 : width < 700 ? 2 : 3;
        final childAspectRatio = width < 320
            ? 0.84
            : width < 700
                ? 0.68
                : 0.74;

        return Padding(
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: width < 320 ? 10 : 14,
            vertical: width < 320 ? 10 : 16,
          ),
          child: GridView.builder(
            physics: physics,
            padding: EdgeInsets.only(bottom: bottomPadding),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: width < 320 ? 8 : 12,
              mainAxisSpacing: width < 320 ? 8 : 12,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: itemBuilder,
          ),
        );
      },
    );
  }
}
