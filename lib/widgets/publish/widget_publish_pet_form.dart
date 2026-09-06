import 'dart:io';
import 'package:appets/core/constants/constants_strings_profile.dart';
import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/validators/validators.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/buttons/widget_buttons.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_process.dart';
import 'package:appets/widgets/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/fields/widget_field_label.dart';
import 'package:appets/widgets/fields/widget_phone_field.dart';
import 'package:appets/widgets/fields/widget_text_field.dart';
import 'package:appets/widgets/publish/widget_attribute_fields.dart';
import 'package:appets/widgets/publish/widget_image_slots_grid.dart';
import 'package:appets/widgets/publish/widget_publication_type_selector.dart';
import 'package:flutter/material.dart';

/// Formulário reutilizável de publicação de pet.
///
/// Contém todos os campos (fotos, tipo, nome, idade,
/// gênero, cidade e descrição), a validação e a
/// confirmação de descarte ao voltar.
class WGPublishPetForm extends StatefulWidget {
  const WGPublishPetForm({super.key});

  @override
  State<WGPublishPetForm> createState() => _WGPublishPetFormState();
}

class _WGPublishPetFormState extends State<WGPublishPetForm> {
  // Quantidade máxima de fotos permitidas.
  static const int _maximumImageCount = 5;

  // Controla a validação do formulário de publicação.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Campos do formulário.
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _raceController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  // Controla a navegação de foco entre os campos pelo teclado.
  final FocusNode _raceFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  // Dados da conta do dono (para pré-preencher o contato por herança).
  UserModel? _owner;

  // Estado do formulário de publicação.
  AppPetGender? _selectedGender = AppPetGender.male;
  AppPetSpecies _selectedSpecies = AppPetSpecies.dog;
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
      final user = AuthService.instance.currentUser;
      if (user == null) return;

      final owner = await FirestoreService.instance.getUser(user.uid);
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
    _raceController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();

    _raceFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  // ACTIONS

  /// Indica se o usuário já preencheu algo no formulário.
  bool get _hasUnsavedChanges {
    return _nameController.text.trim().isNotEmpty ||
        _raceController.text.trim().isNotEmpty ||
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

    final shouldDiscard = await WGConfirmDialog.show(
      context,
      title: PublishStrings.DISCARD_TITLE,
      message: PublishStrings.DISCARD_MESSAGE,
      confirmLabel: PublishStrings.DISCARD_CONFIRM,
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

    final user = AuthService.instance.currentUser;
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

    final result = await Navigator.push<WGProcessResult>(
      context,
      MaterialPageRoute<WGProcessResult>(
        builder: (_) => WGProcessLoadingScreen(
          message: PublishStrings.PUBLISH_LOADING,
          task: () async {
            try {
              // 1. Criar pet no Firestore
              final newPet = Pet(
                id: '',
                ownerId: user.uid,
                name: _nameController.text.trim(),
                race: _raceController.text.trim(),
                species: _selectedSpecies,
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

              final petId = await PetService.instance.createPet(newPet);
              await MyPublicationsService.instance.add(user.uid, petId);

              // 2. Upload das imagens (se houver). Se o Storage falhar
              //    (ex.: ainda não configurado no Firebase), desfaz a
              //    publicação criada para não deixar um pet órfão sem fotos.
              if (_imagePaths.isNotEmpty) {
                try {
                  final imageUrls = <String>[];
                  for (int i = 0; i < _imagePaths.length; i++) {
                    final url = await StorageService.instance.uploadPetImage(
                      petId,
                      i,
                      File(_imagePaths[i]),
                    );
                    imageUrls.add(url);
                  }
                  await PetService.instance.updatePet(petId, {
                    'images': imageUrls,
                  });
                } catch (_) {
                  try {
                    await PetService.instance.deletePet(petId);
                    await MyPublicationsService.instance.remove(
                      user.uid,
                      petId,
                    );
                  } catch (_) {
                    // Melhor esforço: se o rollback falhar, o usuário é
                    // informado do erro e o pet pode ser removido depois.
                  }
                  rethrow;
                }
              }

              return const WGProcessResult.success();
            } on Exception {
              return const WGProcessResult.failure(
                PublishStrings.PUBLISH_ERROR,
              );
            }
          },
        ),
      ),
    );
    if (!mounted) return;

    switch (result?.status) {
      case WGProcessStatus.success:
        WGSnackBar.show(context, PublishStrings.PET_PUBLISHED);
        // D1: contato alterado em relação à conta -> perguntar se atualiza tudo.
        if (_contactChanged(phone, address)) {
          final shouldUpdate = await _confirmUpdateAllPublications();
          if (shouldUpdate && mounted) {
            await _updateAllPublications(user.uid, phone, address);
          }
        }
        if (mounted) Navigator.pop(context, true);
      case WGProcessStatus.failure:
        WGSnackBar.show(context, result!.message!);
      case WGProcessStatus.canceled:
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
    final shouldComplete = await WGActionDialog.show(
      context,
      title: PublishStrings.INCOMPLETE_PROFILE_TITLE,
      message: PublishStrings.INCOMPLETE_PROFILE_MESSAGE,
      actionLabel: PublishStrings.COMPLETE_PROFILE_BUTTON,
      actionIcon: Icons.edit_outlined,
    );

    if (shouldComplete && mounted) {
      Navigator.pushNamed(context, AppRoutes.accountData);
    }
  }

  /// Abre o diálogo Sim/Não para atualizar todas as publicações.
  Future<bool> _confirmUpdateAllPublications() {
    return WGConfirmDialog.show(
      context,
      title: PublishStrings.UPDATE_ALL_PUBLICATIONS_TITLE,
      message: PublishStrings.UPDATE_ALL_PUBLICATIONS_MESSAGE,
      confirmLabel: PublishStrings.UPDATE_ALL_PUBLICATIONS_CONFIRM,
      cancelLabel: PublishStrings.UPDATE_ALL_PUBLICATIONS_CANCEL,
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
        await FirestoreService.instance.updateUser(uid, {
          'phone': phone,
          'address': address,
        });
      }
      final myPets = await PetService.instance.getPetsByOwner(uid);
      for (final pet in myPets) {
        await PetService.instance.updatePet(pet.id, {
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
              WGImageSlotsGrid(
                title: PublishStrings.PHOTOS_TITLE,
                description: PublishStrings.photosGridDescription(
                  _maximumImageCount,
                ),
                maxImages: _maximumImageCount,
                onChanged: _onImageSlotsChanged,
              ),

              const SizedBox(height: 28),

              // TIPO DE PUBLICAÇÃO
              WGFieldLabel(text: PublishStrings.PUBLICATION_TYPE),

              WGPublicationTypeSelector(
                selectedType: _selectedPublicationType,
                onChanged: _onPublicationTypeChanged,
              ),

              const SizedBox(height: 20),

              // NOME
              WGFieldLabel(text: PublishStrings.PET_NAME_LABEL),

              WGTextField(
                controller: _nameController,

                hintText: PublishStrings.PET_NAME_HINT,

                textInputAction: TextInputAction.next,

                onChanged: _onFieldChanged,

                onFieldSubmitted: (_) {
                  _raceFocusNode.requestFocus();
                },

                validator: (value) {
                  if ((value?.trim().length ?? 0) < 2) {
                    return PublishStrings.PET_NAME_REQUIRED;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ESPÉCIE
              WGFieldLabel(text: PublishStrings.SPECIES_LABEL),

              DropdownButtonFormField<AppPetSpecies>(
                initialValue: _selectedSpecies,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: ThemeColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value ?? AppPetSpecies.dog;
                  });
                },
                items: AppPetSpecies.values
                    .map(
                      (species) => DropdownMenuItem(
                        value: species,
                        child: Text(species.label),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 20),

              // RAÇA (opcional)
              WGFieldLabel(text: PublishStrings.PET_RACE_LABEL),

              WGTextField(
                controller: _raceController,
                hintText: PublishStrings.PET_RACE_HINT,
                textInputAction: TextInputAction.next,
                focusNode: _raceFocusNode,
                onChanged: _onFieldChanged,
                onFieldSubmitted: (_) {
                  _phoneFocusNode.requestFocus();
                },
              ),

              const SizedBox(height: 20),

              // IDADE
              WGFieldLabel(text: PublishStrings.AGE),

              WGAgeFields(
                initialValue: _selectedAgeValue,
                initialUnit: _selectedAgeUnit,
                onChanged: _onAgeChanged,
              ),

              const SizedBox(height: 20),

              // GÊNERO
              WGFieldLabel(text: PublishStrings.GENDER),

              WGGenderFields(
                groupValue: _selectedGender,
                onChanged: _onGenderChanged,
              ),

              // TELEFONE DE CONTATO (herdado da conta, editável)
              WGFieldLabel(text: PublishStrings.CONTACT_OWNER_LABEL),

              WGPhoneField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                hintText: PublishStrings.CONTACT_OWNER_HINT,
                textInputAction: TextInputAction.next,
                onChanged: _onFieldChanged,
                onFieldSubmitted: (_) {
                  _addressFocusNode.requestFocus();
                },
                validator: _validatePhone,
              ),

              const SizedBox(height: 20),

              // ENDEREÇO (herdado da conta, editável)
              WGFieldLabel(text: ProfileStrings.ADDRESS_LABEL),

              WGTextField(
                controller: _addressController,
                hintText: PublishStrings.ADDRESS_HINT,
                textInputAction: TextInputAction.next,
                focusNode: _addressFocusNode,
                onChanged: _onFieldChanged,
                onFieldSubmitted: (_) {
                  _descriptionFocusNode.requestFocus();
                },
                validator: (value) {
                  if ((value?.trim().isEmpty ?? true)) {
                    return PublishStrings.ADDRESS_REQUIRED;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // DESCRIÇÃO (opcional)
              WGFieldLabel(text: PublishStrings.ABOUT_PET),

              WGTextField(
                controller: _descriptionController,
                hintText: PublishStrings.ABOUT_PET_HINT,
                maxLines: 6,
              ),

              const SizedBox(height: 32),

              // PUBLICAR
              WGButton(
                text: PublishStrings.PUBLISH_BUTTON,

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
