import 'package:appets/core/constants/constants_strings_legal.dart';
import 'package:appets/models/legal_section_model.dart';
import 'package:appets/widgets/layout/widget_legal_page.dart';
import 'package:flutter/material.dart';

/// Política de Privacidade do APPets.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WGLegalPage(
      title: LegalStrings.PRIVACY_TITLE,
      sections: [
        LegalSectionModel(
          title: LegalStrings.PRIVACY_WHO_TITLE,
          paragraphs: [
            'O APPets é um aplicativo para divulgar pets para adoção, pets desaparecidos e aproximar pessoas interessadas em adoção responsável. Esta política explica como tratamos os dados usados no app.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.PRIVACY_DATA_TITLE,
          paragraphs: [
            'Coletamos os dados do cadastro, como nome e e-mail. Quando você completa o perfil ou publica um anúncio, também podemos tratar telefone, endereço, fotos e as informações que você incluir sobre o pet.',
            'Usamos Firebase Authentication para autenticação, Cloud Firestore para armazenar dados do app, Cloud Storage para fotos e Google Sign-In quando você escolhe entrar com sua conta Google.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.PRIVACY_USE_TITLE,
          paragraphs: [
            'Usamos os dados para criar e manter sua conta, exibir anúncios, permitir favoritos, viabilizar o contato entre interessados e responsáveis e melhorar a segurança e o funcionamento do APPets.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.PRIVACY_SHARE_TITLE,
          paragraphs: [
            'O telefone e as informações de contato inseridos em um anúncio podem ser mostrados a pessoas autenticadas no app para que elas possam iniciar uma conversa pelo WhatsApp. Não vendemos seus dados pessoais.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.PRIVACY_RETENTION_TITLE,
          paragraphs: [
            'Mantemos os dados enquanto sua conta estiver ativa ou pelo tempo necessário para oferecer o serviço, cumprir obrigações legais, prevenir fraudes e resolver conflitos. Você pode solicitar a exclusão da conta pelos canais disponibilizados pelo app.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.PRIVACY_SECURITY_TITLE,
          paragraphs: [
            'Adotamos medidas técnicas e organizacionais razoáveis para proteger os dados. Nenhum serviço digital é totalmente livre de riscos, portanto também recomendamos que você não publique informações desnecessárias.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.PRIVACY_RIGHTS_TITLE,
          paragraphs: [
            'Nos termos da LGPD, você pode solicitar confirmação de tratamento, acesso, correção, anonimização, eliminação, informação sobre compartilhamentos e revisão de consentimento, observados os limites legais.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.PRIVACY_CHILDREN_TITLE,
          paragraphs: [
            'O APPets não é destinado a menores de idade sem a supervisão e o consentimento de responsável legal. Caso identifique dados fornecidos indevidamente, entre em contato conosco.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.PRIVACY_CHANGES_TITLE,
          paragraphs: [
            'Podemos atualizar esta política para refletir mudanças no aplicativo ou na legislação. Quando a alteração for relevante, solicitaremos novo aceite da versão atual.',
          ],
        ),
        LegalSectionModel(
          title: LegalStrings.PRIVACY_CONTACT_TITLE,
          paragraphs: [
            'Para dúvidas sobre privacidade ou para falar com o encarregado pelo tratamento de dados, escreva para privacidade@appets.app.',
          ],
        ),
      ],
    );
  }
}
