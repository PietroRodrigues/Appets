import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/widgets/common/layout/widget_scaffold.dart';

/// Layout base para telas de autenticação com formulário centralizado.
class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.formKey,
    required this.child,
    this.scrollPhysics,
    this.autovalidateMode,
  });

  final GlobalKey<FormState> formKey;
  final Widget child;
  final ScrollPhysics? scrollPhysics;

  /// Modo de validação aplicado ao formulário.
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: ThemeColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

      // Sem resize: o scroll cuida de manter o campo focado visível,
      // evitando o reposicionamento do conteúdo a cada frame do teclado.
      resizeToAvoidBottomInset: false,

      child: Form(
        key: formKey,
        autovalidateMode: autovalidateMode,
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
