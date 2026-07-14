import 'package:flutter/material.dart';

import 'package:appets/widgets/branding/app_auth_header.dart';
import 'package:appets/widgets/buttons/app_button.dart';
import 'package:appets/widgets/buttons/app_outlined_button.dart';
import 'package:appets/widgets/form/app_text_field.dart';
import 'package:appets/widgets/layout/auth_page_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  //══════════════════════════════════════════════════════════════
  // FORM KEY
  //
  // Responsável por controlar e validar todo o formulário.
  // Futuramente utilizaremos para validar os campos antes de
  // criar a conta.
  //══════════════════════════════════════════════════════════════

  final _formKey = GlobalKey<FormState>();


  //══════════════════════════════════════════════════════════════
  // CONTROLLERS
  //
  // Controlam o texto digitado pelo usuário.
  // Assim conseguimos ler o conteúdo de cada campo quando
  // o botão "Criar Conta" for pressionado.
  //══════════════════════════════════════════════════════════════

  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();


  //══════════════════════════════════════════════════════════════
  // STATE
  //
  // Variáveis responsáveis por atualizar a interface.
  // Aqui controlamos se a senha será exibida ou escondida.
  //══════════════════════════════════════════════════════════════

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;


  //══════════════════════════════════════════════════════════════
  // LIFECYCLE
  //
  // Chamado quando esta tela é destruída.
  // Todo Controller precisa ser liberado da memória.
  //══════════════════════════════════════════════════════════════

  @override
  void dispose() {

    _nameController.dispose();

    _emailController.dispose();

    _passwordController.dispose();

    _confirmPasswordController.dispose();

    super.dispose();
  }


  //══════════════════════════════════════════════════════════════
  // NAVIGATION
  //
  // Métodos responsáveis apenas por navegar entre telas.
  // Não devem conter regras de negócio.
  //══════════════════════════════════════════════════════════════

  void _goBack() {
    Navigator.pop(context);
  }


  //══════════════════════════════════════════════════════════════
  // ACTIONS
  //
  // Métodos responsáveis pelas ações da tela.
  // Futuramente aqui chamaremos o Firebase.
  //══════════════════════════════════════════════════════════════

  void _register() {

    // TODO:
    // Criar conta utilizando Firebase Authentication.

  }

  void _togglePasswordVisibility() {

    setState(() {
      _obscurePassword = !_obscurePassword;
    });

  }

  void _toggleConfirmPasswordVisibility() {

    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });

  }


  //══════════════════════════════════════════════════════════════
  // UI
  //
  // Toda a interface gráfica fica daqui para baixo.
  //══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return AuthPageLayout(
     
      formKey: _formKey,
      
      child: Column(
        
        children: [

          const SizedBox(height: 24),

          //----------------------------------------------------------
          // Cabeçalho
          //----------------------------------------------------------

          const AppAuthHeader(
            headline: 'Crie sua conta',
          ),

          const SizedBox(height: 48),

          //----------------------------------------------------------
          // Nome
          //----------------------------------------------------------

          AppTextField(
            controller: _nameController,
            label: 'Nome',
            hintText: 'Digite seu nome completo',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline,
          ),

          const SizedBox(height: 20),

          //----------------------------------------------------------
          // E-mail
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
          // Senha
          //----------------------------------------------------------

          AppTextField(
            controller: _passwordController,
            label: 'Senha',
            hintText: 'Digite sua senha',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
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

          const SizedBox(height: 20),

          //----------------------------------------------------------
          // Confirmar Senha
          //----------------------------------------------------------

          AppTextField(
            controller: _confirmPasswordController,
            label: 'Confirmar Senha',
            hintText: 'Digite novamente sua senha',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: _toggleConfirmPasswordVisibility,
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),

          const SizedBox(height: 32),

          //----------------------------------------------------------
          // Botão Criar Conta
          //----------------------------------------------------------

          AppButton(
            text: 'Criar Conta',
            onPressed: _register,
          ),

          const SizedBox(height: 16),

          //----------------------------------------------------------
          // Voltar para Login
          //----------------------------------------------------------

          AppOutlinedButton(
            text: 'Já possuo uma conta',
            onPressed: _goBack,
          ),

          const Spacer(),

        ],

      ),

    );

  }

}