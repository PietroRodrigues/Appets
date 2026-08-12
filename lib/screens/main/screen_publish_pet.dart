import 'package:flutter/material.dart';
import 'package:appets/models/enums/enum_pet_gender.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/common/widget_scaffold.dart';
import 'package:appets/widgets/common/widget_text_field.dart';
import 'package:appets/widgets/common/widget_button.dart';

/// Formulário para publicar um novo pet na plataforma.
class PublishPetScreen extends StatefulWidget {
  const PublishPetScreen({
    super.key,
  });

  @override
  State<PublishPetScreen> createState() => _PublishPetScreenState();

}

class _PublishPetScreenState extends State<PublishPetScreen> {
  // Controla a validação do formulário de publicação.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Campos do formulário.
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _ageController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  // Estado do formulário de publicação.
  AppPetGender? _selectedGender = AppPetGender.male;
  AppPetAgeUnit _selectedAgeUnit = AppPetAgeUnit.years;
  int? _selectedAgeValue = 1;

  @override
  void dispose() {

    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();

    super.dispose();

  }

  // Publica o pet após validar o formulário.
  void _publishPet() { // Em desenvolvimento.

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // TODO:
    // Implementar publicação futuramente.

  }

  @override
  Widget build(BuildContext context) {

    return AppScaffold(

      child: Form(

        key: _formKey,

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              //--------------------------------------------------
              // CABEÇALHO
              //--------------------------------------------------

              Text(

                'Publicar Pet',

                style: AppTextStyles.heading,

              ),

              const SizedBox(height: 8),

              Text(

                'Preencha as informações do pet para encontrar '
                'um novo lar.',

                style: AppTextStyles.body,

              ),

              const SizedBox(height: 28),

              //--------------------------------------------------
              // NOME
              //--------------------------------------------------

              Text(

                'Nome do pet',

                style: AppTextStyles.subtitle,

              ),

              const SizedBox(height: 8),

              AppTextField(

                controller: _nameController,

                hintText: 'Digite o nome do pet',

              ),

              const SizedBox(height: 20),

              //--------------------------------------------------
              // IDADE
              //--------------------------------------------------

              Text(

                'Idade',

                style: AppTextStyles.subtitle,

              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedAgeValue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _selectedAgeValue = v;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'Informe a idade';
                        return null;
                      },
                      items: (() {
                        final List<int> options = [];
                        switch (_selectedAgeUnit) {
                          case AppPetAgeUnit.years:
                            for (var i = 0; i <= 99; i++) {
                              options.add(i);
                            }
                            break;
                          case AppPetAgeUnit.months:
                            for (var i = 0; i <= 11; i++) {
                              options.add(i);
                            }
                            break;
                          case AppPetAgeUnit.days:
                            for (var i = 0; i <= 31; i++) {
                              options.add(i);
                            }
                            break;
                        }
                        return options
                            .map((n) => DropdownMenuItem<int>(
                                  value: n,
                                  child: Text(n.toString()),
                                ))
                            .toList();
                      })(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<AppPetAgeUnit>(
                      initialValue: _selectedAgeUnit,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _selectedAgeUnit = v ?? AppPetAgeUnit.years;
                          // adjust selected value if out of range
                          final max = _selectedAgeUnit == AppPetAgeUnit.years
                              ? 99
                              : _selectedAgeUnit == AppPetAgeUnit.months
                                  ? 11
                                  : 31;
                          if ((_selectedAgeValue ?? 0) > max) {
                            _selectedAgeValue = max;
                          }
                        });
                      },
                      items: AppPetAgeUnit.values.map((unit) {
                        final label = unit == AppPetAgeUnit.days
                            ? 'dias'
                            : unit == AppPetAgeUnit.months
                                ? 'meses'
                                : 'anos';
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(label),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //--------------------------------------------------
              // GÊNERO
              //--------------------------------------------------

              Text(
                'Gênero',
                style: AppTextStyles.subtitle,
              ),

              const SizedBox(height: 8),

              RadioGroup<AppPetGender>(
                groupValue: _selectedGender,

                onChanged: (value) {

                  setState(() {
                    _selectedGender = value;
                  });

                },

                child: Row(

                  children: [

                    Expanded(

                      child: RadioListTile<AppPetGender>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Macho'),
                        value: AppPetGender.male,
                        activeColor: AppColors.primary,
                      ),

                    ),

                    Expanded(

                      child: RadioListTile<AppPetGender>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Fêmea'),
                        value: AppPetGender.female,
                        activeColor: AppColors.primary,
                      ),

                    ),

                  ],

                ),

              ),

              //--------------------------------------------------
              // CIDADE
              //--------------------------------------------------

              Text(

                'Cidade',

                style: AppTextStyles.subtitle,

              ),

              const SizedBox(height: 8),

              AppTextField(

                controller: _cityController,

                hintText: 'Digite a cidade',

              ),

              const SizedBox(height: 20),

              //--------------------------------------------------
              // DESCRIÇÃO
              //--------------------------------------------------

              Text(

                'Sobre o pet',

                style: AppTextStyles.subtitle,

              ),

              const SizedBox(height: 8),

              AppTextField(
                controller: _descriptionController,
                hintText: 'Conte um pouco sobre o pet',
                maxLines: 6,
              ),

              const SizedBox(height: 32),

              //--------------------------------------------------
              // PUBLICAR
              //--------------------------------------------------

              AppButton(

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
