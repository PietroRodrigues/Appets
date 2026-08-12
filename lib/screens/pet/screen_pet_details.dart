import 'package:flutter/material.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/model_pet.dart';

/// Tela de detalhes com imagens e informações do pet selecionado.
class PetDetailsScreen extends StatefulWidget {
  const PetDetailsScreen({super.key, required this.pet});

  final Pet pet;

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  // Índice da imagem atualmente exibida na galeria.
  int _currentImage = 0;

  String get _formattedAge {
    if (widget.pet.age == 1) {
      return '1 ano';
    }

    return '${widget.pet.age} anos';
  }

  String get _formattedGender {
    return widget.pet.gender.name == 'male' ? 'Macho' : 'Fêmea';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,

        foregroundColor: AppColors.white,

        elevation: 0,

        title: Text(widget.pet.name),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,
              height: 280,
              color: AppColors.surface,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: widget.pet.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.asset(
                          widget.pet.images[index],
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.pet.images.length, (index) {
                      final isActive = index == _currentImage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 12 : 8,
                        height: isActive ? 12 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.secondary.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  //------------------------------------------------
                  // Nome
                  //------------------------------------------------
                  Text(widget.pet.name, style: AppTextStyles.heading),

                  const SizedBox(height: 20),

                  //------------------------------------------------
                  // Informações
                  //------------------------------------------------
                  Row(
                    children: [
                      const Icon(
                        Icons.cake_outlined,
                        color: AppColors.secondary,
                      ),

                      const SizedBox(width: 8),

                      Text(_formattedAge, style: AppTextStyles.body),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.pets, color: AppColors.secondary),

                      const SizedBox(width: 8),

                      Text(_formattedGender, style: AppTextStyles.body),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.secondary,
                      ),

                      const SizedBox(width: 8),

                      Text(widget.pet.city, style: AppTextStyles.body),
                    ],
                  ),

                  const SizedBox(height: 30),

                  //------------------------------------------------
                  // Sobre
                  //------------------------------------------------
                  Text('Sobre', style: AppTextStyles.subtitle),

                  const SizedBox(height: 10),

                  Text(
                    'Este é um texto temporário apenas para montar a interface. ' // Em desenvolvimento.
                    'Futuramente essa descrição será carregada do Firebase com '
                    'as informações cadastradas pelo responsável pelo pet.',

                    style: AppTextStyles.body,
                  ),

                  const SizedBox(height: 40),

                  //------------------------------------------------
                  // Botão
                  //------------------------------------------------
                  SizedBox(
                    width: double.infinity,

                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,

                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),

                      onPressed: () { // Em desenvolvimento.
                        // TODO:
                        // Abrir conversa via WhatsApp.
                      },

                      child: const Text(
                        'Entrar em contato',

                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
