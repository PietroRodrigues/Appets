import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:flutter/material.dart';

/// Campo de seleção reutilizável (dropdown) com estilo consistente do app.
///
/// Garantias anti-overflow: [isExpanded] faz o valor selecionado se ajustar à
/// largura da caixa, e os textos usam uma única linha com ellipsis — o texto
/// nunca sai da caixa do seletor. Não há largura/altura fixa: o campo ocupa
/// as constraints do pai, tornando-se responsivo.
class WGDropdownField extends StatelessWidget {
  const WGDropdownField({
    super.key,
    required this.items,
    required this.hintText,
    this.label,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
  });

  /// Opções de seleção.
  final List<String> items;

  /// Texto de apoio exibido quando nada está selecionado (e no label flutuante
  /// quando [label] não é informado).
  final String hintText;

  /// Rótulo opcional exibido acima do campo ou como label flutuante.
  final String? label;

  /// Ícone opcional à esquerda do campo.
  final IconData? prefixIcon;

  /// Validação do campo (ex.: motivo obrigatório).
  final FormFieldValidator<String>? validator;

  /// Callback disparado quando o valor selecionado muda.
  final ValueChanged<String?>? onChanged;

  /// Callback de salvamento do formulário.
  final FormFieldSetter<String>? onSaved;

  final bool enabled;

  /// Texto de uma opção: frase inteira, quebrando para uma segunda linha
  /// quando não couber em uma (sem reticências e sem estourar a caixa).
  Widget _optionText(String value, AppColors colors) => Text(
        value,
        maxLines: 2,
        softWrap: true,
        style: ThemeTextStyles.body(colors),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DropdownButtonFormField<String>(
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: _optionText(item, colors),
            ),
          )
          .toList(),
      // isExpanded: o valor selecionado se ajusta à largura da caixa, sem
      // estourar o campo (e sem alargar o diálogo).
      isExpanded: true,
      validator: validator,
      onSaved: onSaved,
      onChanged: enabled ? onChanged : null,
      style: ThemeTextStyles.body(colors),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary),
      // Seletor sempre alinhado à caixa: valor centralizado verticalmente e
      // hint legível quando vazio.
      hint: Text(
        hintText,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: ThemeTextStyles.body(
          colors,
        ).copyWith(color: colors.textSecondary),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}
