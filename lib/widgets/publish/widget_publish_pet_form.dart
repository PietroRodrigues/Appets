import 'package:flutter/material.dart';

import 'package:appets/models/enums/enum_pet_gender.dart';
import 'package:appets/models/enums/enum_pet_publication_type.dart';
import 'package:appets/widgets/common/buttons/widget_button.dart';
import 'package:appets/widgets/common/feedback/widget_confirm_dialog.dart';
import 'package:appets/widgets/common/fields/widget_field_label.dart';
import 'package:appets/widgets/common/fields/widget_text_field.dart';
import 'package:appets/widgets/publish/widget_age_fields.dart';
import 'package:appets/widgets/publish/widget_gender_fields.dart';
import 'package:appets/widgets/publish/widget_image_slots_grid.dart';
import 'package:appets/widgets/publish/widget_publication_type_selector.dart';

/// Formulário reutilizável de publicação de pet.
///
/// Contém todos os campos (fotos, tipo, nome, idade,
/// gênero, cidade e descrição), a validação e a
/// confirmação de descarte ao voltar.
class PublishPetForm extends StatefulWidget {
  const PublishPetForm({
    super.key,
  });

  @override
  State<PublishPetForm> createState() => _PublishPetFormState();
}

class _PublishPetFormState extends State<PublishPetForm> {
  // Quantidade máxima de fotos permitidas.
  static const int _maximumImageCount = 5;

  // Controla a validação do formulário de publicação.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Campos do formulário.
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  // Controla a navegação de foco entre os campos pelo teclado.
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  // Estado do formulário de publicação.
  AppPetGender? _selectedGender = AppPetGender.male;
  int? _selectedAgeValue = 1;
  AppPetAgeUnit _selectedAgeUnit = AppPetAgeUnit.years;
  AppPetPublicationType _selectedPublicationType =
      AppPetPublicationType.adoption;

  // Indica se o usuário já adicionou alguma foto.
  bool _hasImages = false;

  @override
  void dispose() {

    _nameController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();

    _cityFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();

  }

  // ACTIONS

  /// Indica se o usuário já preencheu algo no formulário.
  bool get _hasUnsavedChanges {
    return _nameController.text.trim().isNotEmpty ||
        _cityController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _hasImages;
  }

  /// Exibe confirmação antes de descartar o formulário preenchido.
  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldDiscard = await AppConfirmDialog.show(
      context,
      title: 'Descartar alterações?',
      message: 'As informações preenchidas serão perdidas.',
      confirmLabel: 'Sim, descartar',
    );

    return shouldDiscard;
  }

  /// Intercepta o botão voltar para confirmar o descarte do formulário.
  Future<void> _onPopInvokedWithResult(bool didPop, Object? result) async {
    if (didPop) return;

    final shouldDiscard = await _confirmDiscard();

    if (shouldDiscard && mounted) {
      Navigator.pop(context);
    }
  }

  /// Atualiza o estado das fotos ao receber alterações da grade de slots.
  void _onImageSlotsChanged(List<bool> slots) { // Em desenvolvimento.
    _hasImages = slots.any((filled) => filled);
  }

  /// Atualiza o tipo de publicação selecionado.
  void _onPublicationTypeChanged(AppPetPublicationType type) {
    setState(() {
      _selectedPublicationType = type;
    });
  }

  /// Atualiza a idade selecionada a partir dos campos reutilizáveis.
  void _onAgeChanged(int? value, AppPetAgeUnit unit) {
    setState(() {
      _selectedAgeValue = value;
      _selectedAgeUnit = unit;
    });
  }

  /// Atualiza o gênero selecionado.
  void _onGenderChanged(AppPetGender? gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  /// Publica o pet após validar o formulário.
  void _publishPet() { // Em desenvolvimento.

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // TODO:
    // Implementar publicação futuramente.

  }

  // UI
  @override
  Widget build(BuildContext context) {

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,

      child: Form(

        key: _formKey,

        autovalidateMode: AutovalidateMode.onUserInteraction,

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [


              // FOTOS
              AppImageSlotsGrid(
                title: 'Fotos do pet',
                description:
                    'Toque para adicionar (mínimo 1, máximo $_maximumImageCount fotos)',
                maxImages: _maximumImageCount,
                onChanged: _onImageSlotsChanged, // Em desenvolvimento.
              ),

              const SizedBox(height: 28),


              // TIPO DE PUBLICAÇÃO
              AppFieldLabel(text: 'Tipo de publicação'),

              AppPublicationTypeSelector(
                selectedType: _selectedPublicationType,
                onChanged: _onPublicationTypeChanged,
              ),

              const SizedBox(height: 20),


              // NOME
              AppFieldLabel(text: 'Nome do pet'),

              AppTextField(

                controller: _nameController,

                hintText: 'Digite o nome do pet',

                textInputAction: TextInputAction.next,

                onFieldSubmitted: (_) {
                  _cityFocusNode.requestFocus();
                },

                validator: (value) {
                  if ((value?.trim().length ?? 0) < 2) {
                    return 'Informe o nome do pet';
                  }
                  return null;
                },

              ),

              const SizedBox(height: 20),


              // IDADE
              AppFieldLabel(text: 'Idade'),

              AppAgeFields(
                initialValue: _selectedAgeValue,
                initialUnit: _selectedAgeUnit,
                onChanged: _onAgeChanged,
              ),

              const SizedBox(height: 20),


              // GÊNERO
              AppFieldLabel(text: 'Gênero'),

              AppGenderFields(
                groupValue: _selectedGender,
                onChanged: _onGenderChanged,
              ),


              // CIDADE
              AppFieldLabel(text: 'Cidade'),

              AppTextField(

                controller: _cityController,

                hintText: 'Digite a cidade',

                textInputAction: TextInputAction.next,

                focusNode: _cityFocusNode,

                onFieldSubmitted: (_) {
                  _descriptionFocusNode.requestFocus();
                },

                validator: (value) {
                  if ((value?.trim().isEmpty ?? true)) {
                    return 'Informe a cidade';
                  }
                  return null;
                },

              ),

              const SizedBox(height: 20),


              // DESCRIÇÃO
              AppFieldLabel(text: 'Sobre o pet'),

              AppTextField(
                controller: _descriptionController,
                hintText: 'Conte um pouco sobre o pet',
                maxLines: 6,
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 10) {
                    return 'Descreva o pet (mínimo 10 caracteres)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),


              // PUBLICAR
              WidgetButton(

                text: 'Publicar Pet',

                onPressed: _publishPet, // Em desenvolvimento.

              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}
