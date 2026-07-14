import 'package:flutter/material.dart';

import 'package:appets/widgets/layout/app_scaffold.dart';

class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.formKey,
    required this.child,
  });

  final GlobalKey<FormState> formKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - 60,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}