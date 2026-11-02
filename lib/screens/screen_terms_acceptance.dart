import 'package:appets/core/constants/constants_strings_legal.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/auth/widget_auth_button.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:flutter/material.dart';

/// Solicita novo aceite quando a versão dos documentos legais muda.
class TermsAcceptanceScreen extends StatefulWidget {
  const TermsAcceptanceScreen({super.key});

  @override
  State<TermsAcceptanceScreen> createState() => _TermsAcceptanceScreenState();
}

class _TermsAcceptanceScreenState extends State<TermsAcceptanceScreen> {
  bool _accepted = false;
  bool _saving = false;

  Future<void> _accept() async {
    final user = AuthService.instance.currentUser;
    if (user == null || !_accepted) return;
    setState(() => _saving = true);
    try {
      await AuthService.instance.ensureUserDocument(
        UserModel.fromFirebaseUser(
          user,
          termsVersion: LegalStrings.TERMS_VERSION,
        ),
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return WGScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LegalStrings.ACCEPT_TERMS_RENEWAL_TITLE,
                style: ThemeTextStyles.heading(colors),
              ),
              const SizedBox(height: 12),
              Text(
                LegalStrings.ACCEPT_TERMS_RENEWAL_DESCRIPTION,
                style: ThemeTextStyles.body(colors),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.terms),
                child: const Text(LegalStrings.TERMS_TITLE),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                child: const Text(LegalStrings.PRIVACY_TITLE),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _accepted,
                title: const Text('Li e aceito os documentos atualizados.'),
                onChanged: (value) => setState(() => _accepted = value ?? false),
              ),
              const SizedBox(height: 12),
              WGAuthButton(
                text: LegalStrings.ACCEPT_TERMS_BUTTON,
                onPressed: _accepted && !_saving ? _accept : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
