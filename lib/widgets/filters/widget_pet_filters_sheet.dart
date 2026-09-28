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

  static final List<PetFilterOption> speciesOptions = [
    for (final species in AppPetSpecies.values)
      PetFilterOption(
        category: PetFilterCategory.species,
        value: speciesStorageToken(species),
        label: species.label,
      ),
  ];

  static final List<PetFilterOption> genderOptions = [
    for (final gender in AppPetGender.values)
      PetFilterOption(
        category: PetFilterCategory.gender,
        value: genderStorageToken(gender),
        label: gender.label,
      ),
  ];

  static final List<PetFilterOption> publicationTypeOptions = [
    for (final type in AppPetPublicationType.values)
      PetFilterOption(
        category: PetFilterCategory.publicationType,
        value: publicationTypeStorageToken(type),
        label: type.label,
      ),
  ];
}

/// Linha leve de opção do popover de filtros (alternativa ao
/// [CheckboxListTile]): 48px de toque, caixa própria desenhada e sem
/// depender do tema global.
class WGFilterOptionTile extends StatelessWidget {
  const WGFilterOptionTile({
    super.key,
    required this.value,
    required this.label,
    required this.onTap,
  });

  /// Marcado ou não.
  final bool value;

  final String label;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      button: true,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: value ? ThemeColors.primary : null,
                    border: Border.all(
                      color: ThemeColors.primary,
                      width: 1.6,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: value
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: ThemeColors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label, style: ThemeTextStyles.body),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Popover de filtros minimalista, ancorado abaixo do botão de filtro.
///
/// Aparece como um cartão discreto (200px de largura, no máximo 50% da
/// altura da tela) sem título nem cabeçalho. A seleção múltipla (espécie,
/// gênero, tipo e idade) é marcada em caixas de seleção; **fechar aplica**:
/// tocar fora do cartão ou o gesto de voltar devolve o que está marcado
/// (pode ser lista vazia, removendo os filtros). "Limpar tudo" desmarca
/// tudo de uma vez.
///
/// **Uso:** chamar o método estático [show] passando o contexto do botão
/// que abre o popover (âncora).
class WGPetFiltersDialog extends StatefulWidget {
  const WGPetFiltersDialog({
    super.key,
    this.initialOptions = const [],
    this.anchorRect,
  });

  /// Filtros já aplicados, exibidos com o checkbox marcado ao abrir.
  final List<PetFilterOption> initialOptions;

  /// Retângulo (em coordenadas globais) do botão usado como âncora.
  final Rect? anchorRect;

  /// Largura do popover, ajustada para os rótulos curtos.
  static const double panelWidth = 200;

  /// Limite de altura do popover (fração da tela).
  static const double panelHeightFraction = 0.5;

  /// Exibe o popover abaixo do [context] do botão de filtro e devolve as
  /// opções marcadas ao fechar (pode ser uma lista vazia).
  static Future<List<PetFilterOption>?> show(
    BuildContext context, {
    List<PetFilterOption> initialOptions = const [],
  }) {
    final box = context.findRenderObject() as RenderBox?;
    final anchorRect = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;

    return showGeneralDialog<List<PetFilterOption>>(
      context: context,
      // Fechar é feito pelo próprio popover (tocar fora/voltar), aplicando
      // a seleção atual.
      barrierDismissible: false,
      barrierLabel:
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) =>
          WGPetFiltersDialog(initialOptions: initialOptions, anchorRect: anchorRect),
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: child,
        );
      },
    );
  }

  @override
  State<WGPetFiltersDialog> createState() => _WGPetFiltersDialogState();
}

class _WGPetFiltersDialogState extends State<WGPetFiltersDialog>
    with SingleTickerProviderStateMixin {
  late final Set<String> _selectedIds;

  /// Entrada do cartão (Fade + deslize curto a partir do botão).
  late final AnimationController _entrance;

  late final Animation<double> _entranceCurved;

  bool _startedEntrance = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialOptions.map((o) => o.id).toSet();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _entranceCurved = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// Desmarca todos os filtros, mantendo o popover aberto para o usuário
  /// marcar novamente antes de fechar (e aplicar).
  void _clearAll() {
    setState(() => _selectedIds.clear());
  }

  /// Opções atualmente marcadas, na ordem das categorias.
  List<PetFilterOption> _selectedOptions() {
    return [
      for (final group in [
        PetFilterOptions.speciesOptions,
        PetFilterOptions.genderOptions,
        PetFilterOptions.publicationTypeOptions,
        PetFilterOptions.ageOptions,
      ])
        for (final option in group)
          if (_selectedIds.contains(option.id)) option,
    ];
  }

  /// Fecha o popover aplicando a seleção atual.
  void _closeApplying() {
    Navigator.pop(context, _selectedOptions());
  }

  /// Alterna marcação de uma opção.
  void _toggleOption(PetFilterOption option) {
    setState(() {
      if (!_selectedIds.add(option.id)) {
        _selectedIds.remove(option.id);
      }
    });
  }

  /// Expande uma lista de opções em linhas leves.
  List<Widget> _buildOptions(List<PetFilterOption> options) {
    return [
      for (final option in options)
        WGFilterOptionTile(
          value: _selectedIds.contains(option.id),
          label: option.label,
          onTap: () => _toggleOption(option),
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

  /// Constrói uma seção (título + opções) do popover.
  Widget _buildSection(
    PetFilterCategory category,
    List<PetFilterOption> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
          child: Text(
            _categoryLabel(category),
            style: ThemeTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeColors.textSecondary,
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: ThemeColors.divider,
          indent: 16,
          endIndent: 16,
        ),
        ..._buildOptions(options),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reduce motion: abre sem deslize/animação (já visível).
    if (!_startedEntrance) {
      _startedEntrance = true;
      if (MediaQuery.disableAnimationsOf(context)) {
        _entrance.value = 1.0;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _entrance.forward();
        });
      }
    }

    final screen = MediaQuery.sizeOf(context);
    const gap = 8.0;
    final maxHeight = screen.height * WGPetFiltersDialog.panelHeightFraction;

    // Posiciona logo abaixo do botão âncora (borda direita alinhada).
    var left = (widget.anchorRect?.right ?? screen.width) -
        WGPetFiltersDialog.panelWidth;
    var top = (widget.anchorRect?.bottom ?? screen.height) + gap;
    if (top + maxHeight > screen.height) {
      top = screen.height - maxHeight - gap;
    }
    if (left < 0) left = 0;
    if (top < 0) top = 0;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeApplying();
      },
      child: Stack(
        children: [
          // Tocar fora (barreira) fecha aplicando a seleção.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeApplying,
            ),
          ),

          // Popover ancorado abaixo do botão de filtro.
          Positioned(
            left: left,
            top: top,
            width: WGPetFiltersDialog.panelWidth,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: FadeTransition(
                opacity: _entranceCurved,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(_entranceCurved),
                  child: Material(
                    color: ThemeColors.background,
                    elevation: 6,
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // ── "Limpar tudo" (à esquerda) + Fechar X (à direita) ────
                      Material(
                        color: ThemeColors.primary,
                        child: Row(
                          children: [
                            // "Limpar tudo": tocar limpa tudo.
                            Expanded(
                              child: InkWell(
                                onTap: _clearAll,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    HomeStrings.FILTER_CLEAR_ALL,
                                    style: ThemeTextStyles.caption.copyWith(
                                      color: ThemeColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // X: fecha aplicando a seleção (como tocar fora).
                            IconButton(
                              onPressed: _closeApplying,
                              tooltip: HomeStrings.FILTER_CLOSE,
                              icon: const Icon(
                                Icons.close,
                                color: ThemeColors.white,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Opções (rolável) ─────────────────────────────
                      Expanded(
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}