import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/fields/widget_text_field.dart';

/// Janela de diálogo modal reutilizável do app (modular).
///
/// Um único widget atende todos os casos de alerta/confirmação do projeto,
/// controlados pelo parâmetro booleano [isConfirmation] e pela presença
/// dos parâmetros de campo de texto:
///
/// - `isConfirmation: true`  → dois botões lado a lado (Não + Sim);
/// - `isConfirmation: false` → um único botão de ação; com entrada de texto
///   (ex.: [hintText] informado) → exibe um campo e devolve o valor digitado
///   (ex.: senha para excluir a conta).
///
/// **Padrão de confirmação:** os botões usam "Não" (cancela) e "Sim"
/// (confirma) por padrão, e a [message] descreve o que será feito.
///
/// **Uso recomendado:** os métodos estáticos tipados:
/// - [showConfirm]: confirmação sim/não (`isConfirmation: true`, destrutiva);
/// - [showAction]: ação única (`isConfirmation: false`);
/// - [showInput]: captura de texto no mesmo scaffold (campo + erro inline).
///
/// ```dart
/// final confirmed = await WGDialog.showConfirm(
///   context,
///   title: 'Excluir?',
///   message: 'Tem certeza que deseja excluir?',
/// );
///
/// final nome = await WGDialog.showInput(
///   context,
///   title: 'Senha',
///   message: 'Digite sua senha',
///   hintText: 'Sua senha',
///   obscureText: true,
/// );
/// ```
class WGDialog extends StatefulWidget {
  const WGDialog({
    super.key,
    required this.title,
    required this.message,
    required this.isConfirmation,
    required this.confirmLabel,
    this.cancelLabel = SharedStrings.NO,
    this.messageHighlight,
    this.confirmColor = ThemeColors.error,
    this.actionIcon,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.fieldValidator,
    this.errorMessage,
  });

  //══════════════════════════════════════════════════════════════
  // CONTENT
  //══════════════════════════════════════════════════════════════

  final String title;
  final String message;

  /// Trecho de [message] que deve ser destacado em negrito e na cor de
  /// erro (busca sem diferenciar maiúsculas/minúsculas).
  final String? messageHighlight;

  //══════════════════════════════════════════════════════════════
  // BUTTONS
  //══════════════════════════════════════════════════════════════

  /// `true` exibe dois botões (Cancelar + Confirmar); `false` exibe um
  /// único botão de ação.
  final bool isConfirmation;

  /// Rótulo do botão de confirmação ou de ação única.
  final String confirmLabel;

  /// Rótulo do botão de cancelamento (apenas quando [isConfirmation]).
  final String cancelLabel;

  /// Cor do botão de confirmação/ação.
  final Color confirmColor;

  /// Ícone opcional no botão de ação única.
  final IconData? actionIcon;

  //══════════════════════════════════════════════════════════════
  // INPUT MODE
  //══════════════════════════════════════════════════════════════

  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final FormFieldValidator<String>? fieldValidator;

  /// Erro exibido inline sob o campo (ex.: senha incorreta).
  final String? errorMessage;

  //══════════════════════════════════════════════════════════════
  // STATIC HELPERS (APIs tipadas)
  //══════════════════════════════════════════════════════════════

  /// Exibe a confirmação sim/não e retorna `true` ao confirmar
  /// (ou `false` ao cancelar). Botões padrão: "Não" e "Sim".
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = SharedStrings.YES,
    String cancelLabel = SharedStrings.NO,
    String? messageHighlight,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => WGDialog(
        title: title,
        message: message,
        messageHighlight: messageHighlight,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isConfirmation: true,
        confirmColor: ThemeColors.error,
      ),
    );
    return result == true;
  }

  /// Exibe um único botão de ação e retorna `true` quando tocado
  /// (ou `false` quando dispensado). Botão padrão: "OK".
  static Future<bool> showAction(
    BuildContext context, {
    required String title,
    required String message,
    String actionLabel = SharedStrings.OK,
    IconData? actionIcon,
    Color actionColor = ThemeColors.success,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => WGDialog(
        title: title,
        message: message,
        confirmLabel: actionLabel,
        actionIcon: actionIcon,
        isConfirmation: false,
        confirmColor: actionColor,
      ),
    );
    return result ?? false;
  }

  /// Exibe a janela com um campo de texto e devolve o valor digitado
  /// (ou `null` se o usuário cancelar). Botões padrão: "Não" e "Sim".
  static Future<String?> showInput(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = SharedStrings.YES,
    String cancelLabel = SharedStrings.NO,
    required String hintText,
    IconData? prefixIcon,
    bool obscureText = false,
    FormFieldValidator<String>? validator,
    String? errorMessage,
    Color confirmColor = ThemeColors.primary,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => WGDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isConfirmation: true,
        confirmColor: confirmColor,
        hintText: hintText,
        prefixIcon: prefixIcon,
        obscureText: obscureText,
        fieldValidator: validator,
        errorMessage: errorMessage,
      ),
    );
  }

  @override
  State<WGDialog> createState() => _WGDialogState();
}

class _WGDialogState extends State<WGDialog> {
  // Controlador e chave do formulário, usados apenas no modo de texto.
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _formKey;

  bool get _hasField => widget.hintText != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Valida o campo e fecha a janela devolvendo o texto digitado.
  void _submitField() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title, style: ThemeTextStyles.heading),
      content: _buildContent(),
      actions: [
        if (widget.isConfirmation)
          _buildButtonsRow()
        else
          _buildSingleAction(),
      ],
    );
  }

  /// Constrói o corpo: mensagem e, opcionalmente, o campo de texto.
  Widget _buildContent() {
    final message = _buildMessage();

    if (!_hasField) return message;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          message,
          const SizedBox(height: 16),
          WGTextField(
            controller: _controller,
            hintText: widget.hintText!,
            prefixIcon: widget.prefixIcon,
            obscureText: widget.obscureText,
            autofocus: true,
            validator: widget.fieldValidator,
            onFieldSubmitted: (_) => _submitField(),
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.errorMessage!,
              style: ThemeTextStyles.caption.copyWith(
                color: ThemeColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Constrói o texto da mensagem, destacando [messageHighlight]
  /// quando informado.
  Widget _buildMessage() {
    final highlight = widget.messageHighlight;
    final highlightIndex = highlight == null || highlight.isEmpty
        ? -1
        : widget.message.toLowerCase().indexOf(highlight.toLowerCase());

    if (highlightIndex < 0 || highlight!.isEmpty) {
      return Text(widget.message, style: ThemeTextStyles.body);
    }

    return Text.rich(
      TextSpan(
        style: ThemeTextStyles.body,
        children: [
          TextSpan(text: widget.message.substring(0, highlightIndex)),
          TextSpan(
            text: widget.message.substring(
              highlightIndex,
              highlightIndex + highlight.length,
            ),
            style: ThemeTextStyles.body.copyWith(
              color: ThemeColors.error,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: widget.message.substring(highlightIndex + highlight.length),
          ),
        ],
      ),
    );
  }

  /// Linha com dois botões iguais, lado a lado: cancelar (contorno) e
  /// confirmar (preenchido).
  Widget _buildButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: ThemeColors.textSecondary,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.cancelLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: ThemeTextStyles.button.copyWith(
                color: ThemeColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: () => _hasField ? _submitField() : Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: widget.confirmColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.confirmLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: ThemeTextStyles.button.copyWith(color: ThemeColors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// Botão único de ação, com texto (e ícone opcional) centralizado.
  Widget _buildSingleAction() {
    return FilledButton(
      onPressed: () => Navigator.pop(context, true),
      style: FilledButton.styleFrom(
        backgroundColor: widget.confirmColor,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.actionIcon != null) ...[
            Icon(widget.actionIcon, color: ThemeColors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.confirmLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: ThemeTextStyles.button.copyWith(color: ThemeColors.white),
            ),
          ),
        ],
      ),
    );
  }
}