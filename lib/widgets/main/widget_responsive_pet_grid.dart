import 'package:flutter/material.dart';

/// Grid responsivo para listas de pets.
class ResponsivePetGrid extends StatelessWidget {
  const ResponsivePetGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.bottomPadding = 120,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double bottomPadding;

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
