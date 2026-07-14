import 'package:flutter/material.dart';

import 'package:appets/core/routes/app_routes.dart';
import 'package:appets/core/theme/app_text_styles.dart';
import 'package:appets/widgets/branding/app_auth_header.dart';
import 'package:appets/widgets/buttons/app_button.dart';
import 'package:appets/widgets/buttons/app_outlined_button.dart';
import 'package:appets/widgets/form/app_text_field.dart';
import 'package:appets/widgets/layout/auth_page_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //══════════════════════════════════════════════════════════════
  // FORM KEY
  //
  // Controla todo o formulário.
  // Futuramente será utilizada para validar os campos antes
  // de realizar o login.
  //══════════════════════════════════════════════════════════════

  final _formKey = GlobalKey<FormState>();


  //══════════════════════════════════════════════════════════════
  // CONTROLLERS
  //
  // Responsáveis por armazenar o texto digitado pelo usuário.
  // Eles permitem recuperar o conteúdo dos campos sempre que
  // necessário.
  //══════════════════════════════════════════════════════════════

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();


  //══════════════════════════════════════════════════════════════
  // STATE
  //
  // Variáveis responsáveis por atualizar a interface.
  // Sempre que uma delas mudar, utilizaremos setState().
  //══════════════════════════════════════════════════════════════

  bool _obscurePassword = true;


  //══════════════════════════════════════════════════════════════
  // LIFECYCLE
  //
  // Métodos do ciclo de vida desta tela.
  // Aqui liberamos recursos utilizados pelos Controllers.
  //══════════════════════════════════════════════════════════════

  @override
  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }


  //══════════════════════════════════════════════════════════════
  // NAVIGATION
  //
  // Todos os métodos responsáveis por navegar entre telas.
  // Eles não devem conter regras de negócio.
  //══════════════════════════════════════════════════════════════

  void _goToRegister() {
    
    Navigator.pushNamed(
      context,
      AppRoutes.register,
    );

  }

  void _goToForgotPassword() {

    Navigator.pushNamed(
      context,
      AppRoutes.forgotPassword,
    );

  }


  //══════════════════════════════════════════════════════════════
  // ACTIONS
  //
  // Métodos responsáveis pelas ações da tela.
  // Aqui ficará toda a lógica relacionada ao Login.
  //══════════════════════════════════════════════════════════════

  void _login() {

    // TODO:
    // Implementar autenticação utilizando Firebase.

  }

  void _togglePasswordVisibility() {

    setState(() {

      _obscurePassword = !_obscurePassword;

    });

  }


  //══════════════════════════════════════════════════════════════
  // UI
  //
  // Toda a interface gráfica da tela fica organizada nesta
  // seção.
  //══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return AuthPageLayout(
     
      formKey: _formKey,
      
      child: Column(

        children: [

          const SizedBox(height: 24),

          //----------------------------------------------------------
          // Cabeçalho da tela
          //----------------------------------------------------------

          const AppAuthHeader(
            headline: 'Bem-vindo de volta',
          ),

          const SizedBox(height: 48),

          //----------------------------------------------------------
          // Campo de E-mail
          //----------------------------------------------------------

          AppTextField(
            controller: _emailController,
            label: 'E-mail',
            hintText: 'Digite seu e-mail',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 20),

          //----------------------------------------------------------
          // Campo de Senha
          //----------------------------------------------------------

          AppTextField(
            controller: _passwordController,
            label: 'Senha',
            hintText: 'Digite sua senha',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: _togglePasswordVisibility,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),

          const SizedBox(height: 12),

          //----------------------------------------------------------
          // Recuperação de senha
          //----------------------------------------------------------

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _goToForgotPassword,
              child: Text(
                'Esqueci minha senha',
                style: AppTextStyles.body,
              ),
            ),
          ),

          const SizedBox(height: 24),

          //----------------------------------------------------------
          // Botão Entrar
          //----------------------------------------------------------

          AppButton(
            text: 'Entrar',
            onPressed: _login,
          ),

          const SizedBox(height: 16),

          //----------------------------------------------------------
          // Botão Criar Conta
          //----------------------------------------------------------

          AppOutlinedButton(
            text: 'Criar Conta',
            onPressed: _goToRegister,
          ),

          const Spacer(),

        ],

      ),

    );

  }

}