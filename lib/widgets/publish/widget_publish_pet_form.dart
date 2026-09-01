import 'dart:io';

import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/validators/validators.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/common/buttons/widget_buttons.dart';
import 'package:appets/widgets/common/feedback/widget_process_loading.dart';
import 'package:appets/widgets/common/feedback/widget_confirm_dialog.dart';
import 'package:appets/widgets/common/feedback/widget_action_dialog.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/common/fields/widget_fields.dart';
import 'package:appets/widgets/publish/widget_attribute_fields.dart';
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

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _addressController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  // Controla a navegação de foco entre os campos pelo teclado.
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  // Dados da conta do dono (para pré-preencher o contato por herança).
  UserModel? _owner;

  // Estado do formulário de publicação.
  AppPetGender? _selectedGender = AppPetGender.male;
  int? _selectedAgeValue = 1;
  AppPetAgeUnit _selectedAgeUnit = AppPetAgeUnit.years;
  AppPetPublicationType _selectedPublicationType =
      AppPetPublicationType.adoption;

  // Indica se o usuário já adicionou alguma foto.
  bool _hasImages = false;

  // Evita publicações duplicadas enquanto o envio está em andamento.
  bool _isPublishing = false;

  // Lista de caminhos das imagens selecionadas.
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadOwnerContact();
  }

  // Carrega o contato da conta do dono para pré-preencher os campos.
  Future<void> _loadOwnerContact() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return;

      final owner = await FirestoreService().getUser(user.uid);
      if (!mounted) return;
      setState(() {
        _owner = owner;
      });
      if (owner != null) {
        _phoneController.text = owner.phone;
        _addressController.text = owner.address;
      }
    } catch (_) {
      // Se a busca falhar (ex.: ambiente sem Firebase), os campos
      // permanecem vazios/editáveis e a publicação segue o fluxo normal.
    }
  }

  @override
  void dispose() {

    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();

    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();

  }

  // ACTIONS

  /// Indica se o usuário já preencheu algo no formulário.
  bool get _hasUnsavedChanges {
    return _nameController.text.trim().isNotEmpty ||
        _phoneController.text.trim().isNotEmpty ||
        _addressController.text.trim().isNotEmpty ||
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

  /// Valida o celular de contato (obrigatório, 11 dígitos, WhatsApp).
  String? _validatePhone(String? value) =>
      AppValidators.validateCellPhone(value);

  /// Publica o pet após validar o formulário.
  void _publishPet() async {
    if (_isPublishing) return;

    final user = AuthService().currentUser;
    if (user == null) return;

    // Perfil incompleto (sem celular/endereço) -> orientar a completar o
    // cadastro antes de validar os demais campos (evita erros confusos).
    if (!_hasContactFilled) {
      _redirectToCompleteProfile();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isPublishing = true;
    FocusManager.instance.primaryFocus?.unfocus();

    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    final result = await Navigator.push<AppProcessResult>(
      context,
      MaterialPageRoute<AppProcessResult>(
        builder: (_) => AppProcessLoadingScreen(
          message: AppStrings.publishLoading,
          task: () async {
            try {
              // 1. Criar pet no Firestore
              final newPet = Pet(
                id: '',
                ownerId: user.uid,
                name: _nameController.text.trim(),
                age: _selectedAgeValue ?? 1,
                ageUnit: _selectedAgeUnit,
                gender: _selectedGender ?? AppPetGender.male,
                address: address,
                ownerPhone: phone,
                ownerAddress: address,
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

              return const AppProcessResult.success();
            } on Exception {
              return const AppProcessResult.failure(AppStrings.publishError);
            }
          },
        ),
      ),
    );
    if (!mounted) return;

    switch (result?.status) {
      case AppProcessStatus.success:
        AppSnackBar.show(context, AppStrings.petPublished);
        // D1: contato alterado em relação à conta -> perguntar se atualiza tudo.
        if (_contactChanged(phone, address)) {
          final shouldUpdate = await _confirmUpdateAllPublications();
          if (shouldUpdate && mounted) {
            await _updateAllPublications(user.uid, phone, address);
          }
        }
        if (mounted) Navigator.pop(context, true);
      case AppProcessStatus.failure:
        AppSnackBar.show(context, result!.message!);
      case AppProcessStatus.canceled:
      case null:
        break;
    }

    _isPublishing = false;
  }

  // Indica se os campos de contato obrigatórios estão corretos
  // (celular válido e endereço preenchido).
  bool get _hasContactFilled =>
      _phoneController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty;

  // Indica se o formulário está completo para publicar. Usado apenas
  // para a cor do botão; os erros de campo só aparecem ao publicar.
  bool get _isFormComplete {
    if ((_nameController.text.trim().length) < 2) return false;
    if (AppValidators.validateCellPhone(_phoneController.text) != null) {
      return false;
    }
    if (_addressController.text.trim().isEmpty) return false;
    return true;
  }

  // Recalcula o estado para atualizar a cor do botão ao digitar.
  void _onFieldChanged(String _) {
    setState(() {});
  }

  // Compara o contato informado com o da conta.
  bool _contactChanged(String phone, String address) {
    final ownerPhone = _owner?.phone ?? '';
    final ownerAddress = _owner?.address ?? '';
    return phone != ownerPhone || address != ownerAddress;
  }

  /// Mostra o diálogo orientando a completar o cadastro e, ao clicar em
  /// "Completar cadastro", navega para a tela de dados da conta.
  Future<void> _redirectToCompleteProfile() async {
    final shouldComplete = await AppActionDialog.show(
      context,
      title: AppStrings.incompleteProfileTitle,
      message: AppStrings.incompleteProfileMessage,
      actionLabel: AppStrings.completeProfileButton,
      actionIcon: Icons.edit_outlined,
    );

    if (shouldComplete && mounted) {
      Navigator.pushNamed(context, AppRoutes.accountData);
    }
  }

  /// Abre o diálogo Sim/Não para atualizar todas as publicações.
  Future<bool> _confirmUpdateAllPublications() {
    return AppConfirmDialog.show(
      context,
      title: AppStrings.updateAllPublicationsTitle,
      message: AppStrings.updateAllPublicationsMessage,
      confirmLabel: AppStrings.updateAllPublicationsConfirm,
      cancelLabel: AppStrings.updateAllPublicationsCancel,
    );
  }

  // Atualiza a conta e todas as publicações do dono com o novo contato.
  Future<void> _updateAllPublications(
    String uid,
    String phone,
    String address,
  ) async {
    try {
      if (_owner != null) {
        await FirestoreService().updateUser(uid, {
          'phone': phone,
          'address': address,
        });
      }
      final myPets = await PetService().getPetsByOwner(uid);
      for (final pet in myPets) {
        await PetService().updatePet(pet.id, {
          'ownerPhone': phone,
          'ownerAddress': address,
        });
      }
    } catch (_) {
      // Falha silenciosa: a publicação atual já foi gravada corretamente.
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

                onChanged: _onFieldChanged,

                onFieldSubmitted: (_) {
                  _phoneFocusNode.requestFocus();
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


              // TELEFONE DE CONTATO (herdado da conta, editável)
              AppFieldLabel(text: AppStrings.contactOwnerLabel),

              AppPhoneField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                hintText: AppStrings.contactOwnerHint,
                textInputAction: TextInputAction.next,
                onChanged: _onFieldChanged,
                onFieldSubmitted: (_) {
                  _addressFocusNode.requestFocus();
                },
                validator: _validatePhone,
              ),

              const SizedBox(height: 20),

              // ENDEREÇO (herdado da conta, editável)
              AppFieldLabel(text: AppStrings.addressLabel),

              AppTextField(
                controller: _addressController,
                hintText: AppStrings.addressHint,
                textInputAction: TextInputAction.next,
                focusNode: _addressFocusNode,
                onChanged: _onFieldChanged,
                onFieldSubmitted: (_) {
                  _descriptionFocusNode.requestFocus();
                },
                validator: (value) {
                  if ((value?.trim().isEmpty ?? true)) {
                    return AppStrings.addressRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),


              // DESCRIÇÃO (opcional)
              AppFieldLabel(text: AppStrings.aboutPet),

              AppTextField(
                controller: _descriptionController,
                hintText: AppStrings.aboutPetHint,
                maxLines: 6,
              ),

              const SizedBox(height: 32),


              // PUBLICAR
              AppButton(

                text: AppStrings.publishButton,

                onPressed: _publishPet,

                backgroundColor: _isFormComplete
                    ? ThemeColors.success
                    : ThemeColors.disabled,

              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}
