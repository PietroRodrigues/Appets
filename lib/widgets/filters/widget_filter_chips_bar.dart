import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';
import 'package:flutter/material.dart';

/// Barra horizontal de filtros ativos, exibida abaixo do cabeçalho.
///
/// Mostra os filtros aplicados lado a lado em uma fileira rolável;
/// cada chip tem um X à direita que remove apenas aquele filtro.
class WGFilterChipsBar extends StatelessWidget {
  const WGFilterChipsBar({
    super.key,
    required this.options,
    required this.onRemove,
  });

  /// Filtros atualmente aplicados.
  final List<PetFilterOption> options;

  /// Chamado quando o usuário toca no X de um chip.
  final ValueChanged<PetFilterOption> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          return _FilterChip(option: option, onRemove: onRemove);
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.option, required this.onRemove});

  final PetFilterOption option;
  final ValueChanged<PetFilterOption> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
          Text(
            option.label,
            style: ThemeTextStyles.caption.copyWith(color: ThemeColors.white),
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: () => onRemove(option),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
            icon: const Icon(
              Icons.close,
              size: 16,
              color: ThemeColors.white,
            ),
            tooltip: HomeStrings.FILTER_REMOVE,
          ),
        ],
      ),
    );
  }
}