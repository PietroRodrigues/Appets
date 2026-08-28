import 'dart:io';

import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/models/enums/enums_pet.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/common/buttons/widget_button.dart';
import 'package:appets/widgets/common/feedback/widget_confirm_dialog.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
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
class AppPublishPetForm extends StatefulWidget {
  const AppPublishPetForm({
    super.key,
  });

  @override
  State<AppPublishPetForm> createState() => _AppPublishPetFormState();
}

class _AppPublishPetFormState extends State<AppPublishPetForm> {
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

  // Lista de caminhos das imagens selecionadas.
  List<String> _imagePaths = [];

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
      title: AppStrings.discardTitle,
      message: AppStrings.discardMessage,
      confirmLabel: AppStrings.discardConfirm,
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
  void _onImageSlotsChanged(List<String> paths) {
    _hasImages = paths.isNotEmpty;
    _imagePaths = paths;
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
  void _publishPet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) return;

    // 1. Criar pet no Firestore
    final newPet = Pet(
      id: '',
      ownerId: user.uid,
      name: _nameController.text.trim(),
      age: _selectedAgeValue ?? 1,
      ageUnit: _selectedAgeUnit,
      gender: _selectedGender ?? AppPetGender.male,
      city: _cityController.text.trim(),
      description: _descriptionController.text.trim(),
      publicationType: _selectedPublicationType,
      images: [],
    );

    final petId = await PetService().createPet(newPet);

    // 2. Upload das imagens (se houver)
    if (_imagePaths.isNotEmpty) {
      final imageUrls = <String>[];
      for (int i = 0; i < _imagePaths.length; i++) {
        final url = await StorageService().uploadPetImage(
          petId,
          i,
          File(_imagePaths[i]),
        );
        imageUrls.add(url);
      }
      await PetService().updatePet(petId, {'images': imageUrls});
    }

    // 3. Voltar para a Home
    if (mounted) {
      AppSnackBar.show(context, AppStrings.petPublished);
      Navigator.pop(context);
    }
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
                title: AppStrings.photosTitle,
                description: AppStrings.photosGridDescription(_maximumImageCount),
                maxImages: _maximumImageCount,
                onChanged: _onImageSlotsChanged,
              ),

              const SizedBox(height: 28),


              // TIPO DE PUBLICAÇÃO
              AppFieldLabel(text: AppStrings.publicationType),

              AppPublicationTypeSelector(
                selectedType: _selectedPublicationType,
                onChanged: _onPublicationTypeChanged,
              ),

              const SizedBox(height: 20),


              // NOME
              AppFieldLabel(text: AppStrings.petNameLabel),

              AppTextField(

                controller: _nameController,

                hintText: AppStrings.petNameHint,

                textInputAction: TextInputAction.next,

                onFieldSubmitted: (_) {
                  _cityFocusNode.requestFocus();
                },

                validator: (value) {
                  if ((value?.trim().length ?? 0) < 2) {
                    return AppStrings.petNameRequired;
                  }
                  return null;
                },

              ),

              const SizedBox(height: 20),


              // IDADE
              AppFieldLabel(text: AppStrings.age),

              AppAgeFields(
                initialValue: _selectedAgeValue,
                initialUnit: _selectedAgeUnit,
                onChanged: _onAgeChanged,
              ),

              const SizedBox(height: 20),


              // GÊNERO
              AppFieldLabel(text: AppStrings.gender),

              AppGenderFields(
                groupValue: _selectedGender,
                onChanged: _onGenderChanged,
              ),


              // CIDADE
              AppFieldLabel(text: AppStrings.city),

              AppTextField(

                controller: _cityController,

                hintText: AppStrings.cityHint,

                textInputAction: TextInputAction.next,

                focusNode: _cityFocusNode,

                onFieldSubmitted: (_) {
                  _descriptionFocusNode.requestFocus();
                },

                validator: (value) {
                  if ((value?.trim().isEmpty ?? true)) {
                    return AppStrings.cityRequired;
                  }
                  return null;
                },

              ),

              const SizedBox(height: 20),


              // DESCRIÇÃO
              AppFieldLabel(text: AppStrings.aboutPet),

              AppTextField(
                controller: _descriptionController,
                hintText: AppStrings.aboutPetHint,
                maxLines: 6,
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 10) {
                    return AppStrings.aboutPetRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),


              // PUBLICAR
              AppButton(

                text: AppStrings.publishButton,

                onPressed: _publishPet,

              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}
