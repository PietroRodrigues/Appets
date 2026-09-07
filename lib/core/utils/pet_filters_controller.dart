import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';
import 'package:flutter/widgets.dart';

/// Controlador dos filtros ativos de uma tela de feed.
///
/// Centraliza o estado dos filtros (compartilhado entre o cabeçalho,
/// que abre a janela e exibe os chips, e o grid, que aplica o AND) e
/// notifica ouvintes a cada mudança — espelho do [SearchQueryController].
class PetFiltersController extends ValueNotifier<List<PetFilterOption>> {
  PetFiltersController() : super(const []);

  bool get isActive => value.isNotEmpty;

  /// Valores normalizados das opções (1 por categoria selecionada),
  /// usados como tokens do pré-filtro do servidor.
  List<String> get tags => [for (final option in value) option.value];

  /// Abre a janela de filtros; aplica o resultado ([null] = cancelado).
  Future<void> openDialog(BuildContext context) async {
    final options = await WGPetFiltersDialog.show(
      context,
      initialOptions: value,
    );
    if (options == null) return;
    value = options;
  }

  /// Remove um único filtro (X do chip).
  void remove(PetFilterOption option) {
    value = value.where((o) => o.id != option.id).toList();
  }

  /// Limpa todos os filtros, notificando os ouvintes com `[]`.
  void clear() => value = const [];
}