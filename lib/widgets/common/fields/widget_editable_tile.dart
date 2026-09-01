import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/common/fields/widget_fields.dart';

/// Tile de dados do usuário que permite edição inline.
///
/// Quando [isEditing] é `true`, o valor exibido é substituído por um
/// campo de texto focado (com teclado ativo). Ao confirmar (Enter) ou
/// sair do campo, o valor é devolvido via [onCommit] para o pai salvar
/// localmente. O pai é responsável por controlar qual tile está em
/// edição ([onStartEditing] + [isEditing]) para permitir apenas um
/// campo aberto por vez.
class AppEditableTile extends StatefulWidget {
  const AppEditableTile({
    super.key,
    required this.icon,
    required this.title,
    required this.initialValue,
    required this.committedValue,
    required this.onCommit,
    required this.onStartEditing,
    required this.isEditing,
    this.phone = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  // PROPERTIES
  final IconData icon;
  final String title;

  /// Valor carregado da conta (restaurado ao cancelar).
  final String initialValue;

  /// Valor atualmente salvo localmente pelo pai.
  final String committedValue;

  /// Devolve o novo valor ao confirmar a edição.
  final ValueChanged<String> onCommit;

  /// Notifica o pai que este tile quer entrar em edição.
  final VoidCallback onStartEditing;

  /// Indica se este tile está em modo de edição.
  final bool isEditing;

  /// Se `true`, usa o campo de telefone com máscara.
  final bool phone;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;

  @override
  State<AppEditableTile> createState() => _AppEditableTileState();
}

class _AppEditableTileState extends State<AppEditableTile> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.committedValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Quando o estado de edição muda, sincroniza o texto e o foco.
  @override
  void didUpdateWidget(covariant AppEditableTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing && !oldWidget.isEditing) {
      _controller.text = widget.committedValue;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  void _commit() {
    widget.onCommit(_controller.text.trim());
  }

  void _onTapTile() {
    if (!widget.isEditing) {
      widget.onStartEditing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isEditing
            ? ThemeColors.cardHighlight
            : ThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: widget.isEditing
            ? Border.all(color: ThemeColors.primary, width: 1.5)
            : null,
      ),
      child: InkWell(
        onTap: _onTapTile,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              // ÍCONE
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ThemeColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: ThemeColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              // CONTEÚDO
              Expanded(
                child: widget.isEditing
                    ? _buildEditor()
                    : _buildDisplay(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Estado de exibição: título + valor atual.
  Widget _buildDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: ThemeTextStyles.subtitle.copyWith(
            fontSize: 15,
            color: ThemeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.committedValue.isEmpty
              ? AppStrings.editHint
              : widget.committedValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ThemeTextStyles.caption.copyWith(
            color: widget.committedValue.isEmpty
                ? ThemeColors.hint
                : ThemeColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Estado de edição: campo de texto com foco e teclado ativo.
  Widget _buildEditor() {
    final field = widget.phone
        ? AppPhoneField(
            controller: _controller,
            focusNode: _focusNode,
            hintText: widget.committedValue.isEmpty
                ? widget.title
                : '',
            textInputAction:
                widget.textInputAction ?? TextInputAction.done,
            validator: widget.validator,
            onFieldSubmitted: (_) => _commit(),
          )
        : AppTextField(
            controller: _controller,
            focusNode: _focusNode,
            hintText: widget.committedValue.isEmpty
                ? widget.title
                : '',
            keyboardType: widget.keyboardType,
            textInputAction:
                widget.textInputAction ?? TextInputAction.done,
            validator: widget.validator,
            onFieldSubmitted: (_) => _commit(),
          );

    return Focus(
      onFocusChange: (hasFocus) {
        // Ao sair do campo (blur), commit local.
        if (!hasFocus && mounted) {
          _commit();
        }
      },
      child: FormField<String>(
        validator: widget.validator,
        builder: (fieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              field,
              if (fieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    fieldState.errorText ?? '',
                    style: ThemeTextStyles.caption.copyWith(
                      color: ThemeColors.error,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
