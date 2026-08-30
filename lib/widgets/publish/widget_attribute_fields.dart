import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enums_app.dart';

/// Campos de idade reutilizáveis do formulário de publicação.
///
/// Exibe dropdowns de valor e unidade (dias/meses/anos),
/// ajustando automaticamente o limite máximo do valor
/// conforme a unidade selecionada.
///
/// Notifica o pai a cada alteração através de [onChanged].
class AppAgeFields extends StatefulWidget {
  const AppAgeFields({
    super.key,
    this.initialValue,
    this.initialUnit = AppPetAgeUnit.years,
    this.onChanged,
  });

  // PROPERTIES
  final int? initialValue;
  final AppPetAgeUnit initialUnit;

  /// Notifica o valor e a unidade selecionados.
  final void Function(int? value, AppPetAgeUnit unit)? onChanged;

  @override
  State<AppAgeFields> createState() => _AppAgeFieldsState();
}

class _AppAgeFieldsState extends State<AppAgeFields> {
  // Estado dos campos de idade.
  int? _selectedValue;
  AppPetAgeUnit _selectedUnit = AppPetAgeUnit.years;

  @override
  void initState() {
    super.initState();

    _selectedValue = widget.initialValue;
    _selectedUnit = widget.initialUnit;
  }

  // ACTIONS

  /// Limite máximo de valor conforme a unidade selecionada.
  int get _maxValue {
    switch (_selectedUnit) {
      case AppPetAgeUnit.years:
        return 99;

      case AppPetAgeUnit.months:
        return 11;

      case AppPetAgeUnit.days:
        return 31;
    }
  }

  /// Notifica o pai sobre o estado atual dos campos.
  void _notifyChanged() {
    widget.onChanged?.call(_selectedValue, _selectedUnit);
  }

  // UI

  /// Decoração padronizada dos dropdowns.
  InputDecoration get _decoration {
    return InputDecoration(
      filled: true,
      fillColor: ThemeColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // VALOR
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<int>(
            initialValue: _selectedValue,
            decoration: _decoration,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });

              _notifyChanged();
            },
            validator: (value) {
              if (value == null) return AppStrings.ageRequired;
              return null;
            },
            items: [
              for (var i = 1; i <= _maxValue; i++)
                DropdownMenuItem<int>(
                  value: i,
                  child: Text(i.toString()),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // UNIDADE
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<AppPetAgeUnit>(
            initialValue: _selectedUnit,
            decoration: _decoration,
            onChanged: (unit) {
              setState(() {
                _selectedUnit = unit ?? AppPetAgeUnit.years;

                // Ajusta o valor caso fique fora do limite da nova unidade.
                if ((_selectedValue ?? 0) > _maxValue) {
                  _selectedValue = _maxValue;
                }
              });

              _notifyChanged();
            },
            items: AppPetAgeUnit.values.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(unit.label),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Campos de gênero reutilizáveis do formulário de publicação.
///
/// Exibe as opções "Macho" e "Fêmea" lado a lado.
class AppGenderFields extends StatelessWidget {
  const AppGenderFields({
    super.key,
    this.groupValue,
    required this.onChanged,
  });

  // PROPERTIES

  /// Gênero atualmente selecionado.
  final AppPetGender? groupValue;

  /// Notifica o gênero selecionado (pode ser `null`).
  final ValueChanged<AppPetGender?> onChanged;

  // UI
  @override
  Widget build(BuildContext context) {
    return RadioGroup<AppPetGender>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<AppPetGender>(
              contentPadding: EdgeInsets.zero,
              title: Text(AppPetGender.male.label),
              value: AppPetGender.male,
              activeColor: ThemeColors.primary,
            ),
          ),

          Expanded(
            child: RadioListTile<AppPetGender>(
              contentPadding: EdgeInsets.zero,
              title: Text(AppPetGender.female.label),
              value: AppPetGender.female,
              activeColor: ThemeColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}