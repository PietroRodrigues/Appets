import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/widgets/common/widget_scaffold.dart';

/// Layout base para telas de autenticação com formulário centralizado.
class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.formKey,
    required this.child,
    this.scrollPhysics,
  });

  final GlobalKey<FormState> formKey;
  final Widget child;
  final ScrollPhysics? scrollPhysics;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: scrollPhysics,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(child: child),
              ),
            );
          },
        ),
      ),
    );
  }
}
