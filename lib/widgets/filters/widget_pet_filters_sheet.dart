import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/core/utils/storage_tokens.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:flutter/material.dart';

/// Categoria de um filtro selecionável.
enum PetFilterCategory { species, gender, publicationType, age }

/// Uma opção selecionável de filtro (apresentação visual apenas).
class PetFilterOption {
  const PetFilterOption({
    required this.category,
    required this.value,
    required this.label,
  });

  final PetFilterCategory category;

  final String value;

  /// Rótulo exibido na janela e na barra de chips.
  final String label;

  /// Identificador único da opção (categoria + valor).
  String get id => '${category.name}:$value';
}

/// Relação das opções disponíveis, agrupadas por categoria.
class PetFilterOptions {
  PetFilterOptions._();

  static const ageOptions = [
    PetFilterOption(
      category: PetFilterCategory.age,
      value: kAgeBracketFilhote,
      label: HomeStrings.FILTER_AGE_PUPPY,
    ),
    PetFilterOption(
      category: PetFilterCategory.age,
      value: kAgeBracketJovem,
      label: HomeStrings.FILTER_AGE_YOUNG,
    ),
    PetFilterOption(
      category: PetFilterCategory.age,
      value: kAgeBracketAdulto,
      label: HomeStrings.FILTER_AGE_ADULT,
    ),
  ];

  static List<PetFilterOption> get speciesOptions => [
    for (final species in AppPetSpecies.values)
      PetFilterOption(
        category: PetFilterCategory.species,
        value: speciesStorageToken(species),
        label: species.label,
      ),
  ];

  static List<PetFilterOption> get genderOptions => [
    for (final gender in AppPetGender.values)
      PetFilterOption(
        category: PetFilterCategory.gender,
        value: genderStorageToken(gender),
        label: gender.label,
      ),
  ];

  static List<PetFilterOption> get publicationTypeOptions => [
    for (final type in AppPetPublicationType.values)
      PetFilterOption(
        category: PetFilterCategory.publicationType,
        value: publicationTypeStorageToken(type),
        label: type.label,
      ),
  ];
}

/// Janela central de filtros com listas de opções e checkboxes.
///
/// Exibe categorias (espécie, gênero, tipo e idade) com seleção
/// múltipla via caixa de seleção à esquerda. O botão "Filtrar"
/// fecha a janela devolvendo as opções marcadas; fechar pelo X
/// (ou tocar fora) descarta a seleção.
///
/// **Uso:** chamar o método estático [show] para exibir e obter
/// a lista de opções aplicadas.
class WGPetFiltersDialog extends StatefulWidget {
  const WGPetFiltersDialog({super.key, this.initialOptions = const []});

  /// Filtros já aplicados, exibidos com o checkbox marcado ao abrir.
  final List<PetFilterOption> initialOptions;

  /// Exibe a janela e retorna as opções marcadas ao tocar "Filtrar"
  /// (pode ser uma lista vazia, indicando que todos os filtros foram
  /// removidos); devolve `null` quando fechada pelo X ou pela barreira.
  static Future<List<PetFilterOption>?> show(
    BuildContext context, {
    List<PetFilterOption> initialOptions = const [],
  }) async {
    final result = await showDialog<List<PetFilterOption>>(
      context: context,
      builder: (_) => WGPetFiltersDialog(initialOptions: initialOptions),
    );
    return result;
  }

  @override
  State<WGPetFiltersDialog> createState() => _WGPetFiltersDialogState();
}

class _WGPetFiltersDialogState extends State<WGPetFiltersDialog> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialOptions.map((o) => o.id).toSet();
  }

  /// Expande uma lista de opções em linhas com checkbox.
  List<Widget> _buildOptions(List<PetFilterOption> options) {
    return [
      for (final option in options)
        CheckboxListTile(
          value: _selectedIds.contains(option.id),
          onChanged: (_) {
            setState(() {
              if (!_selectedIds.add(option.id)) {
                _selectedIds.remove(option.id);
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(option.label, style: ThemeTextStyles.body),
        ),
    ];
  }

  /// Rótulo de uma categoria de filtro.
  String _categoryLabel(PetFilterCategory category) {
    switch (category) {
      case PetFilterCategory.species:
        return HomeStrings.FILTER_SPECIES;

      case PetFilterCategory.gender:
        return HomeStrings.FILTER_GENDER;

      case PetFilterCategory.publicationType:
        return HomeStrings.FILTER_PUBLICATION_TYPE;

      case PetFilterCategory.age:
        return HomeStrings.FILTER_AGE;
    }
  }

  /// Constrói uma seção (título + opções) da janela.
  Widget _buildSection(
    PetFilterCategory category,
    List<PetFilterOption> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Text(
            _categoryLabel(category),
            style: ThemeTextStyles.subtitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textPrimary,
            ),
          ),
        ),
        ..._buildOptions(options),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkboxTheme = CheckboxThemeData(
      side: const BorderSide(color: ThemeColors.primary, width: 1.8),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return ThemeColors.primary;
        return null;
      }),
      checkColor: WidgetStatePropertyAll(ThemeColors.white),
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: ThemeColors.background,
      child: Theme(
        data: Theme.of(context).copyWith(checkboxTheme: checkboxTheme),
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Cabeçalho ───────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ThemeColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        HomeStrings.FILTERS_TITLE,
                        style: ThemeTextStyles.heading.copyWith(
                          color: ThemeColors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: HomeStrings.CLEAR_SEARCH,
                      icon: const Icon(
                        Icons.close,
                        size: 24,
                        color: ThemeColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Opções (rolável) ────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSection(
                        PetFilterCategory.species,
                        PetFilterOptions.speciesOptions,
                      ),
                      _buildSection(
                        PetFilterCategory.gender,
                        PetFilterOptions.genderOptions,
                      ),
                      _buildSection(
                        PetFilterCategory.publicationType,
                        PetFilterOptions.publicationTypeOptions,
                      ),
                      _buildSection(
                        PetFilterCategory.age,
                        PetFilterOptions.ageOptions,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Rodapé ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: FilledButton(
                  onPressed: () {
                    final selected = <PetFilterOption>[
                      for (final group in [
                        PetFilterOptions.speciesOptions,
                        PetFilterOptions.genderOptions,
                        PetFilterOptions.publicationTypeOptions,
                        PetFilterOptions.ageOptions,
                      ])
                        for (final option in group)
                          if (_selectedIds.contains(option.id)) option,
                    ];
                    Navigator.pop(context, selected);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: ThemeColors.onPrimary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    HomeStrings.FILTER_APPLY,
                    style: ThemeTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
