# APPets

Aplicativo **Android** para publicação de pets, com foco em **adoção** e
**pets perdidos**. Responsáveis publicam pets com fotos e informações
básicas, e interessados podem explorar, buscar e favoritar.

## Funcionalidades

- **Autenticação** — login e cadastro com e-mail/senha, login com **Google**,
  recuperação de senha e logout, integrados com o Firebase Auth
- **Feed de pets** — lista de pets publicados, carregada do Firestore, com
  busca e filtro
- **Detalhes do pet** — galeria de fotos, informações (idade, gênero, cidade
  e tipo de publicação), descrição e contato via WhatsApp
- **Publicar pet** — formulário com fotos (upload para o Storage), tipo de
  publicação (adoção/perdido), nome, idade, gênero, cidade e descrição,
  com confirmação antes de descartar alterações
- **Favoritos** — pets salvos pelo usuário
- **Minhas publicações** — gerenciamento dos pets publicados pelo usuário
  (filtro por dono no Firestore)
- **Perfil** — dados da conta, configurações e desconexão
- **Dados da conta** — dados carregados do Firestore e **exclusão da conta**,
  com confirmação em duas etapas e reautenticação por senha

> Os dados vêm do Firestore (Autenticação, Pets, Usuários) e as fotos dos
> pets são armazenadas no Storage.

## Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| Flutter / Dart | SDK ^3.12.0 | Framework principal |
| firebase_core / firebase_auth | ^3.12.1 / ^5.5.4 | Inicialização e autenticação |
| cloud_firestore | ^5.6.9 | Persistência de usuários e pets |
| firebase_storage | ^12.4.1 | Upload de imagens dos pets |
| google_sign_in | ^6.2.2 | Login com conta Google |
| image_picker | ^1.1.2 | Seleção de fotos no formulário |
| url_launcher | ^6.3.1 | Contato via WhatsApp |
| google_fonts | ^8.1.0 | Fonte Poppins |

Versão atual do app: **1.0.0+1**

## Arquitetura

O código está organizado em camadas:

- `lib/core/services/` — serviços de backend (`AuthService`,
  `FirestoreService`, `PetService`, `StorageService`)
- `lib/core/navigation/` — controle de navegação por abas
- `lib/core/constants/` — strings e assets centralizados
- `lib/models/` — modelos de dados (`Pet`, `UserModel`, enums)
- `lib/screens/` — telas organizadas por área (auth, main, pet, settings, splash)
- `lib/widgets/` — componentes reutilizáveis por área

## Status do projeto

Em desenvolvimento. Busca e filtro ainda são placeholders e algumas ações
(ex.: troca de avatar e edição de nome) exibem o aviso *"em desenvolvimento"*
enquanto as integrações não são implementadas. O backend Firebase já está
integrado e operacional.
