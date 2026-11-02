import 'package:appets/core/constants/constants_strings_legal.dart';
import 'package:appets/models/legal_section_model.dart';
import 'package:appets/widgets/layout/widget_legal_page.dart';
import 'package:flutter/material.dart';

/// Termos de Uso do APPets.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WGLegalPage(
      title: LegalStrings.TERMS_TITLE,
      sections: [
        LegalSectionModel(
          title: LegalStrings.TERMS_ACCEPTANCE_TITLE,
          paragraphs: [
            'Ao criar uma conta ou usar o APPets, você concorda com estes Termos de Uso e com a Política de Privacidade, versão 2026-11-01.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_SERVICE_TITLE,
          paragraphs: [
            'O APPets é uma plataforma para publicar e encontrar anúncios de adoção e de pets desaparecidos. O aplicativo facilita o encontro entre usuários, mas não realiza a adoção nem representa qualquer anunciante.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_ACCOUNT_TITLE,
          paragraphs: [
            'Você é responsável por manter seus dados corretos, proteger o acesso à sua conta e usar informações verdadeiras ao publicar ou entrar em contato com outras pessoas.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_USE_TITLE,
          paragraphs: [
            'Use o APPets de forma legal, respeitosa e segura. É proibido usar o serviço para fraude, assédio, exploração animal, spam, coleta indevida de dados ou qualquer atividade que viole direitos de terceiros.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_CONTENT_TITLE,
          paragraphs: [
            'Você é responsável pelos textos, fotos, telefone, endereço e demais informações de seus anúncios. Publique apenas conteúdo que tenha direito de usar e que descreva o pet de forma honesta.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_REPORT_TITLE,
          paragraphs: [
            'Temos tolerância zero a conteúdo impróprio, ilegal, enganoso, violento, discriminatório ou que coloque animais ou pessoas em risco. Podemos remover conteúdo e limitar contas que descumprirem estes termos.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_ADOPTION_TITLE,
          paragraphs: [
            'A adoção deve ser responsável. Antes de decidir, converse com o responsável, avalie as condições de cuidado e respeite a legislação e o bem-estar do animal. O APPets não garante a conduta dos usuários nem o estado de saúde dos pets.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_CONTACT_TITLE,
          paragraphs: [
            'O contato entre usuários pode ocorrer pelo WhatsApp a partir do telefone informado no anúncio. Tome cuidados ao conversar e evite compartilhar dados sensíveis ou realizar pagamentos fora de canais confiáveis.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_LIABILITY_TITLE,
          paragraphs: [
            'Na extensão permitida pela lei, o APPets não se responsabiliza por negociações, adoções, encontros, informações ou condutas de usuários. Decisões relacionadas a um anúncio são de responsabilidade de quem as toma.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_IP_TITLE,
          paragraphs: [
            'A marca, o aplicativo e seus elementos são protegidos por lei. O conteúdo publicado continua sendo de responsabilidade de quem o enviou, que autoriza sua exibição no APPets para operar o serviço.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_SUSPENSION_TITLE,
          paragraphs: [
            'Podemos suspender ou encerrar o acesso em caso de violação destes termos, risco à segurança, fraude ou obrigação legal, sempre que isso for razoavelmente necessário.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_CHANGES_TITLE,
          paragraphs: [
            'Podemos atualizar estes termos. Quando a mudança exigir novo consentimento, pediremos que você aceite a versão atual antes de continuar usando o aplicativo.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.TERMS_LAW_TITLE,
          paragraphs: [
            'Estes termos são regidos pelas leis brasileiras. Para dúvidas, entre em contato por privacidade@appets.app.',
          ],
        ),
      ],
    );
  }
}
