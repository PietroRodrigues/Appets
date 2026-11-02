// ignore_for_file: constant_identifier_names

/// Textos e motivos disponíveis no fluxo de denúncia de anúncios.
class ReportStrings {
  ReportStrings._();

  static const REPORT_ACTION = 'Denunciar';
  static const REPORT_TITLE = 'Denunciar publicação';
  static const REPORT_DESCRIPTION =
      'Conte-nos o que há de errado neste anúncio. Sua denúncia será analisada.';
  static const REPORT_REASON_LABEL = 'Motivo da denúncia';
  static const REPORT_REASON_REQUIRED = 'Selecione um motivo.';
  static const REPORT_SEND = 'Enviar';
  static const REPORT_CANCEL = 'Cancelar';
  static const REPORT_SUCCESS =
      'Denúncia enviada. Obrigado por ajudar a manter o APPets seguro.';
  static const REPORT_ERROR =
      'Não foi possível enviar a denúncia. Tente novamente.';

  static const reasons = <String>[
    'Conteúdo enganoso ou fraude',
    'Maus-tratos ou risco ao animal',
    'Conteúdo impróprio ou ofensivo',
    'Spam ou anúncio duplicado',
    'Outro motivo',
  ];
}
