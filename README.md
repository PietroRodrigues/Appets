# APPets

Aplicativo mobile desenvolvido em **Flutter** para conectar pessoas interessadas em adoção de animais e facilitar a divulgação de pets perdidos.

O APPets reúne publicações de animais em um único lugar, permitindo explorar anúncios, pesquisar por pets, aplicar filtros, salvar favoritos e entrar em contato com os responsáveis.

## Objetivo

Centralizar anúncios de adoção e de animais perdidos em uma plataforma simples e acessível, facilitando a descoberta de pets e o contato entre quem publica e quem procura.

## Funcionalidades

- **Feed de animais** — visualização de publicações em cards, com carregamento paginado.
- **Busca** — pesquisa de pets por termos relacionados ao nome e à descrição, com tratamento de acentos e variações de texto.
- **Filtros** — refinamento dos resultados por tipo de publicação, espécie, gênero e idade.
- **Detalhes do pet** — galeria de imagens, informações do animal, localização, descrição e opções de contato.
- **Publicação de anúncios** — cadastro de pets para adoção ou divulgação de animais perdidos, com informações e fotos.
- **Favoritos** — possibilidade de salvar publicações e acompanhar os animais selecionados.
- **Minhas publicações** — gerenciamento dos anúncios criados pela conta.
- **Perfil e conta** — edição de dados pessoais e configurações da conta.
- **Autenticação** — cadastro e login por e-mail e senha, além de autenticação com Google.
- **Contato e compartilhamento** — acesso ao contato do responsável pelo anúncio via WhatsApp e compartilhamento de publicações.

## Tecnologias utilizadas

| Tecnologia | Utilização |
|---|---|
| **Flutter** | Desenvolvimento da interface mobile |
| **Dart** | Linguagem principal |
| **Firebase Authentication** | Cadastro e autenticação de usuários |
| **Cloud Firestore** | Armazenamento de usuários, pets, favoritos e publicações |
| **Firebase Storage** | Armazenamento das imagens |
| **Google Sign-In** | Autenticação com conta Google |
| **image_picker** | Seleção de imagens do dispositivo |
| **flutter_image_compress** | Compressão de imagens antes do envio |
| **cached_network_image** | Carregamento e cache de imagens |
| **url_launcher** | Abertura de contato via WhatsApp |
| **share_plus** | Compartilhamento de anúncios |
| **Poppins** | Tipografia da interface |

## Capturas de tela

As telas principais do aplicativo incluem:

- **Início** — feed de animais disponíveis para adoção ou divulgação.
- **Filtros** — seleção de critérios para refinar a busca.
- **Detalhes do pet** — informações completas e opção de contato com o responsável.

<img width="2248" height="1640" alt="Image" src="https://github.com/user-attachments/assets/d7b5b5a0-665c-46a1-928a-d922792f8af1" />


## Estrutura do projeto

O código está organizado em camadas para separar configuração, modelos de dados, telas e componentes reutilizáveis.

```
lib/
├── core/       # Configurações, serviços, tema e recursos compartilhados
├── models/     # Modelos e estruturas de dados
├── screens/    # Telas e fluxos da aplicação
├── widgets/    # Componentes reutilizáveis da interface
├── app.dart    # Configuração principal do aplicativo
└── main.dart   # Ponto de entrada
```

## Como executar

### Requisitos

- Flutter SDK compatível com Dart **3.12.0** ou superior.
- Android Studio ou VS Code com as ferramentas Flutter.
- Projeto Firebase configurado para o aplicativo Android.

### Instalação

Clone o repositório:

```bash
git clone https://github.com/PietroRodrigues/Appets.git
cd Appets
```

Instale as dependências:

```bash
flutter pub get
```

Configure o Firebase para o ambiente Android e execute:

```bash
flutter run
```

## Testes

Execute os testes automatizados com:

```bash
flutter test
```

Para verificar problemas de análise estática:

```bash
flutter analyze
```

## Status do projeto

O APPets está em desenvolvimento contínuo. O projeto já conta com autenticação, integração com Firebase, feed paginado, busca, filtros, detalhes dos pets, publicação e gerenciamento de anúncios, favoritos e recursos de perfil e conta.

---

Projeto desenvolvido como estudo prático de desenvolvimento mobile e engenharia de software.
