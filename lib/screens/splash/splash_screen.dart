import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/branding/app_logo.dart';
import '../../widgets/loading/app_loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // =====================================================
    // Aqui ficará toda a inicialização do aplicativo
    // =====================================================
    //
    // await Firebase.initializeApp();
    // await carregarConfig();
    // await verificarLogin();
    // await carregarCache();
    //
    // =====================================================

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // TODO:
    // Navigator.pushReplacement(...)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Spacer(),

                AppLogo(width: 240),

                const SizedBox(height: 24),

                Text(
                  AppStrings.slogan,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.slogan,
                ),

                const Spacer(),

                const AppLoading(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}