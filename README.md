# APPets

Aplicativo para publicação de pets, com foco em **adoção** e **pets perdidos**.
Responsáveis publicam pets com fotos e informações básicas, e interessados
podem explorar, buscar e favoritar.

## Funcionalidades

- **Autenticação** — login, cadastro e recuperação de senha
  (fluxo funcional; integração real pendente)
- **Feed de pets** — lista de pets publicados com busca e filtro
- **Detalhes do pet** — galeria de fotos, informações (idade, gênero,
  cidade e tipo de publicação) e contato
- **Publicar pet** — formulário com fotos, tipo de publicação
  (adoção/perdido), nome, idade, gênero, cidade e descrição,
  com confirmação antes de descartar alterações
- **Favoritos** — pets salvos pelo usuário
- **Minhas publicações** — gerenciamento dos pets publicados pelo usuário
- **Perfil** — dados da conta, configurações e desconexão

> Atualmente os dados são simulados (`mock_pets`). A integração com o
> Firebase (Authentication e Firestore) está planejada.

## Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| Flutter / Dart | SDK ^3.12.0 | Framework principal |
| google_fonts | ^8.1.0 | Fonte Poppins |
| Material Icons | — | Ícones da interface |

Versão atual do app: **1.0.0+1**

## Como executar

1. Clone o repositório e acesse a pasta do projeto:

```bash
git clone <url-do-repositorio>
cd appets
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Execute o aplicativo:

```bash
flutter run
```

## Status do projeto

Em desenvolvimento. Algumas ações da interface exibem o aviso
*"em desenvolvimento"* enquanto as integrações não são implementadas.
