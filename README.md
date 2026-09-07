# 🐾 APPets

> Aplicativo **Flutter** para publicação de pets — **adoção** e **pets perdidos** — com backend **Firebase** integrado.

O **APPets** é um projeto de estudo de engenharia de software mobile: um
aplicativo onde responsáveis publicam pets disponíveis para adoção ou que
perderam, e interessados exploram, buscam e salvam como favoritos os pets.
Tudo em tempo real, com autenticação, controle de conta e um feed
responsivo e paginado.

---

## Sobre o projeto

O app resolve um problema real: hoje, anúncios de adoção e *pets perdidos*
se espalham por grupos de WhatsApp e posts que se perdem rápido. O APPets
centraliza isso em um lugar só, com:

- **Publicação simples** — nome, idade, gênero, espécie, raça, endereço,
  telefone do responsável e fotos (com validação de telefone BR);
- **Busca inteligente** — digite qualquer termo do nome ou da descrição;
  o app encontra o pet mesmo com acentos ou letras diferentes
  ("poo" → "poodle");
- **Favoritos reativos** — salve pets e veja a lista atualizar em todas as
  telas na hora;
- **Resposta rápida** — contato direto via WhatsApp usando o telefone
  carimbado no anúncio.

Tecnicamente, é um exercício de arquitetura em camadas, estado reativo,
integração com o ecossistema Firebase e UI responsiva em Flutter.

---

## Funcionalidades

| Módulo | O que faz |
|---|---|
| 🔐 **Autenticação** | E-mail/senha, **Google**, recuperação de senha, reautenticação e exclusão de conta. Perfil é criado automaticamente no Firestore |
| 🏠 **Feed** | Lista paginada de todos os pets (stream + *load more* ao rolar), pull-to-refresh e estados de vazio/busca |
| 🔎 **Busca por tokens** | Home busca no servidor (`arrayContainsAny` sobre `searchTokens`, sem dependência de texto exato); Favoritos e Minhas Publicações filtram client-side |
| 🎛️ **Filtros** | Espécie, gênero, faixa de idade e tipo (adoção/perdido) em bottom sheet; pré-filtro no servidor + filtro exato no cliente (`petMatchesFilters`); chips ativos com limpeza |
| 🐕 **Detalhes** | Galeria de fotos, espécie · raça, idade, gênero, endereço, descrição e contato via WhatsApp |
| ➕ **Publicar** | Formulário com validação, tipo de publicação (adoção/perdido), espécie (9 opções) e gestão de fotos |
| ⭐ **Favoritos** | Estado global reativo com atualização otimista, rollback e limpeza de órfãos |
| 📄 **Minhas publicações** | Aba dedicada com FAB de publicar, busca local e sincronização reativa (backfill automático) |
| 👤 **Perfil / Conta** | Edição inline de nome, telefone e endereço; exclusão de conta com confirmação em duas etapas e sem deixar pets órfãos |

---

## Stack

| Tecnologia | Versão | Uso |
|---|---|---|
| Flutter / Dart | SDK ^3.12.0 | Framework principal |
| firebase_core / firebase_auth | ^3.12.1 / ^5.5.4 | Inicialização e autenticação |
| cloud_firestore | ^5.6.9 | Persistência de usuários, pets, favoritos e publicações |
| firebase_storage | ^12.4.1 | Upload de imagens dos pets |
| google_sign_in | ^6.2.2 | Login com conta Google |
| image_picker | ^1.1.2 | Seleção de fotos no formulário |
| url_launcher | ^6.3.1 | Contato via WhatsApp |
| google_fonts | ^8.1.0 | Fonte Poppins |
| flutter_lints | ^6.0.0 | Qualidade de código |
| flutter_test | SDK | 150 testes automatizados |

Versão atual do app: **1.0.0+1** · Orientação fixa **retrato**.

---

## Arquitetura

Padrão de camadas com **serviços singleton** e estado reativo via
`ValueNotifier`:

```
lib/
├── core/
│   ├── constants/      # strings e assets por domínio (auth, home, publish…)
│   ├── extensions/     # exibição formatada do Pet (idade, gênero, espécie·raça)
│   ├── navigation/     # navegação por abas
│   ├── services/       # Auth, Firestore, Pet, Storage, Favorites, MyPublications
│   ├── theme/          # cores e tema
│   ├── utils/          # busca e filtros: tokens, controladores e storage_tokens (PT)
│   └── validators/     # validação de telefone BR com máscara
├── models/             # Pet, UserModel e enums (espécie, tipo, filtro, gênero)
├── screens/            # telas (login, home, favoritos, publicações, perfil…)
└── widgets/            # componentes por tema (auth, feed, fields, filters, feedback…)
```

### Decisões técnicas que merecem destaque

- **Feed paginado com cursor** — a Home e a aba Minhas Publicações leem
  o Firestore em páginas de 20 itens (`startAfterDocument`), detectando
  `hasMore` com um pedido de +1 item. Nada de carregar a coleção inteira.
- **Busca sem depender do texto exato** — tokens normalizados
  (minúsculas + sem acento) gravados no documento; a Home consulta com
  `arrayContainsAny` e as outras abas filtram localmente.
- **Favoritos e publicações reativos** — estado global em memória com
  atualização otimista, rollback em falha, limpeza de órfãos e reset ao
  deslogar. Todas as telas reagem instantaneamente.
- **Exclusão de conta segura** — apaga pets (Firestore + Storage) **antes**
  do Auth; se a limpeza falhar, a exclusão é abortada para nunca deixar
  dados órfãos.
- **Filtros híbridos** — a Home pré-filtra no servidor com
  `arrayContainsAny` sobre `specifications` (superset) e o cliente aplica o
  AND exato por categoria (`petMatchesFilters`); evita trazer a coleção
  inteira sem perder precisão.
- **Dados padronizados em PT‑BR** — species, gender, ageUnit,
  publicationType e specifications são persistidos em PT normalizado (sem
  acento); a leitura tolera valores legados em inglês e um backfill isolado
  (`lib/core/backfill/pet_tokens_*`) migra os pets do dono a cada login.
- **UI responsiva** — grid que alterna 1/2/3 colunas conforme a largura,
  tipografia Poppins e widgets reutilizáveis por tema.

---

## Como executar

```bash
flutter pub get
flutter run
```

> Requisitos: Flutter SDK ^3.12.0 e um **Projeto Firebase** configurado
> (GoogleService-Info / google-services.json, planos gratuitos de Auth,
> Firestore e Storage). O app roda em **Android**; as pastas web/windows/
> linux/macos existem apenas pela geração padrão do template.

### Testes

```bash
flutter test        # 150 testes
flutter analyze     # sem issues
```

---

## Status do projeto

Em desenvolvimento ativo. O backbone (auth, backend, feed paginado, busca e
filtros) está funcional; a busca e o filtro da Home exigem os índices
compostos no console do Firestore (`searchTokens` já criado; `specifications`
a criar). Faltam: edição de pet, edição de e-mail/senha, troca de avatar,
GPS, permissões/fotos com Storage ativo e polish (compartilhar). Suíte com
150 testes. O plano detalhado está em [`BACKLOG.txt`](./BACKLOG.txt).

---

## Licença

Projeto de estudo/portfólio, sem vínculo comercial.