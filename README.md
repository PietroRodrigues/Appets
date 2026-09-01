# APPets

Aplicativo **Android** para publicação de pets, com foco em **adoção** e
**pets perdidos**. Responsáveis publicam pets com fotos e informações
básicas, e interessados podem explorar, buscar e favoritar.

## Funcionalidades

- **Autenticação** — login e cadastro com e-mail/senha, login com **Google**,
  recuperação de senha e logout, integrados com o Firebase Auth. No login
  social, o cadastro do usuário (com foto de perfil) é criado
  automaticamente no Firestore
- **Feed de pets** — lista de pets publicados, carregada do Firestore, com
  busca e filtro; pull-to-refresh; estado vazio com botão para publicar o
  primeiro pet
- **Detalhes do pet** — galeria de fotos, informações (idade, gênero,
  endereço e tipo de publicação), descrição e contato via WhatsApp (usando
  telefone carimbado no pet)
- **Publicar pet** — formulário com fotos (upload para o Storage), tipo de
  publicação (adoção/perdido), nome, idade, gênero, telefone do responsável
  (com máscara e validação), endereço e descrição (opcional); gate de
  cadastro incompleto redireciona para completar dados; confirmação antes
  de descartar alterações
- **Favoritos** — pets salvos pelo usuário com sincronização reativa entre
  todas as telas e limpeza automática de favoritos órfãos
- **Minhas publicações** — gerenciamento dos pets publicados pelo usuário
  (filtro por dono no Firestore); pull-to-refresh
- **Perfil** — dados da conta, configurações e desconexão
- **Dados da conta** — edição inline de nome, telefone e endereço (com
  validação de telefone), dados carregados do Firestore e **exclusão da
  conta**, com confirmação em duas etapas e reautenticação por senha

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

## Orientação

O aplicativo é fixo em **tela vertical (retrato)**, independente da
orientação do aparelho.

## Arquitetura

O código está organizado em camadas:

- `lib/core/services/` — serviços de backend (`AuthService`,
  `FirestoreService`, `PetService`, `StorageService`, `FavoritesService`)
- `lib/core/navigation/` — controle de navegação por abas
- `lib/core/constants/` — strings e assets centralizados
- `lib/core/validators/` — validadores (telefone com máscara BR)
- `lib/models/` — modelos de dados (`Pet`, `UserModel`, enums)
- `lib/screens/` — telas organizadas por área (auth, main, pet, settings, splash)
- `lib/widgets/` — componentes reutilizáveis por área

## Status do projeto

Em desenvolvimento. Busca e filtro ainda são placeholders e algumas ações
(ex.: troca de avatar, compartilhar pet, edição de e-mail/senha) exibem o
aviso *"em desenvolvimento"*. A edição de dados da conta (nome, telefone,
endereço) já é funcional com edição inline e validação. O backend Firebase
está integrado e operacional.
