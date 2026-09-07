import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/utils/pet_filters.dart';
import 'package:appets/core/utils/search_tokens.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';

/// Grid responsivo para listas de pets com lista global interna.
///
/// Mantém os pets carregados e aplica filtros baseado no [filter]
/// informado:
///
/// - [AppPetFilter.all] → feed paginado de todos os pets (stream na
///   1ª página, +[PetService.pageSize] ao rolar)
/// - [AppPetFilter.favorites] → busca direta pelos IDs favoritados
///   (sem paginação, reage a [FavoritesService])
/// - [AppPetFilter.myPublications] → busca direta pelos IDs das
///   publicações do usuário (sem paginação, reage a
///   [MyPublicationsService])
///
/// Quando [searchQuery] não está vazio, a busca é executada no servidor
/// (tokens) para Home, e client-side para Favoritos e Minhas Publicações.
///
/// Quando [filterOptions] está ativo, o Home usa um pré-filtro do servidor
/// (`specifications` via `arrayContainsAny`, quando houver até 10 tags e não
/// houver busca) e o **AND exato por categoria é sempre aplicado no cliente**
/// às páginas recebidas — a autoridade final do resultado. Favoritos e
/// Minhas Publicações filtra direto em memória.
class WGResponsivePetGrid extends StatefulWidget {
  const WGResponsivePetGrid({
    super.key,
    required this.filter,
    required this.itemBuilder,
    this.searchQuery = '',
    this.filterOptions,
    this.emptyBuilder,
    this.padding,
    this.bottomPadding = 16,
    this.topSliverPadding = 8,
    this.physics,
  });

  /// Filtro que determina a estratégia de consulta.
  final AppPetFilter filter;

  /// Termo de busca enviado pelo usuário (via botão 🔍 ou Enter).
  final String searchQuery;

  /// Filtros ativos compartilhados com o cabeçalho (opcional).
  final ValueListenable<List<PetFilterOption>>? filterOptions;

  /// Builder que constrói cada card do grid.
  final Widget Function(BuildContext context, Pet pet) itemBuilder;

  /// Builder exibido quando a lista filtrada está vazia.
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Padding externo do grid.
  final EdgeInsetsGeometry? padding;

  /// Padding inferior para ultrapassar a barra de navegação.
  final double bottomPadding;

  /// Padding superior da primeira sliver do grid.
  final double topSliverPadding;

  /// Física de rolagem do grid.
  final ScrollPhysics? physics;

  @override
  State<WGResponsivePetGrid> createState() => WGResponsivePetGridState();
}

class WGResponsivePetGridState extends State<WGResponsivePetGrid> {
  List<Pet> _items = [];

  bool _isLoading = true;
  bool _hasMore = false;
  bool _isLoadingMore = false;

  QueryDocumentSnapshot? _lastDoc;
  StreamSubscription<PetsPage>? _sub;
  final ScrollController _scrollController = ScrollController();

  /// Listenable de filtros atualmente observado.
  ValueListenable<List<PetFilterOption>>? _filterListenable;

  /// Tags usadas no pré-filtro do feed Home atual (com paginação).
  List<String>? _prefilterTags;

  /// Identificador da consulta atual; consultas antigas são ignoradas.
  int _loadId = 0;

  bool get _isSearching => widget.searchQuery.trim().isNotEmpty;

  /// Opções de filtro ativas (compartilhadas com o cabeçalho).
  List<PetFilterOption> get _activeFilterOptions =>
      widget.filterOptions?.value ?? const [];

  /// Tags para o pré-filtro do servidor no Home: somente com filtros
  /// ativos, sem busca e com no máximo 10 valores (limite do Firestore).
  /// `null` → feed paginado normal (o AND do cliente ainda vale).
  List<String>? get _serverPrefilterTags {
    final options = _activeFilterOptions;
    if (options.isEmpty || _isSearching) return null;
    final tags = options.map((o) => o.value).toSet().toList();
    if (tags.length > 10) return null;
    return tags;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    FavoritesService.instance.favoriteIds.addListener(_onFavoritesChanged);
    MyPublicationsService.instance.myPetIds.addListener(_onMyPublicationsChanged);
    _filterListenable = widget.filterOptions;
    _filterListenable?.addListener(_onFiltersChanged);
    _setup();
  }

  @override
  void didUpdateWidget(covariant WGResponsivePetGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterOptions != widget.filterOptions) {
      oldWidget.filterOptions?.removeListener(_onFiltersChanged);
      _filterListenable = widget.filterOptions;
      _filterListenable?.addListener(_onFiltersChanged);
    }
    if (oldWidget.filter != widget.filter ||
        oldWidget.searchQuery != widget.searchQuery) {
      _setup();
    }
  }

  @override
  void dispose() {
    _filterListenable?.removeListener(_onFiltersChanged);
    _sub?.cancel();
    FavoritesService.instance.favoriteIds.removeListener(_onFavoritesChanged);
    MyPublicationsService.instance.myPetIds
        .removeListener(_onMyPublicationsChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Recarrega quando o conjunto de filtros muda.
  void _onFiltersChanged() {
    if (mounted) _setup();
  }

  void _onFavoritesChanged() {
    if (widget.filter == AppPetFilter.favorites && mounted) {
      _setup();
    }
  }

  void _onMyPublicationsChanged() {
    if (widget.filter == AppPetFilter.myPublications && mounted) {
      _setup();
    }
  }

  // ── Configuração da fonte de dados ───────────────────────────────

  void _setup() {
    _sub?.cancel();
    _loadId++;
    _items = [];
    _isLoading = true;
    _hasMore = false;
    _lastDoc = null;
    _prefilterTags = null;
    setState(() {});

    if (_isSearching) {
      _startSearch(widget.searchQuery.trim());
    } else {
      _startFeed();
    }
  }

  void _startFeed() {
    final id = _loadId;
    switch (widget.filter) {
      case AppPetFilter.all:
        _hasMore = true;
        final tags = _serverPrefilterTags;
        _prefilterTags = tags;
        if (tags != null) {
          _sub = PetService.instance.watchFilteredFirstPage(tags).listen(
            (page) => _onFeedPage(id, page),
            onError: (Object e, StackTrace st) => _onLoadError(id, e, st),
          );
          return;
        }
        _sub = PetService.instance.watchFirstPage().listen(
          (page) => _onFeedPage(id, page),
          onError: (Object e, StackTrace st) => _onLoadError(id, e, st),
        );

      case AppPetFilter.favorites:
        _loadFavorites(id);

      case AppPetFilter.myPublications:
        _loadMyPublications(id);
    }
  }

  void _startSearch(String term) {
    final id = _loadId;
    switch (widget.filter) {
      case AppPetFilter.all:
        PetService.instance
            .searchPetsByTokens(term)
            .then(
              (page) => _onSearchResult(id, page.pets),
              onError: (Object e, StackTrace st) => _onLoadError(id, e, st),
            );

      case AppPetFilter.favorites:
        // Carrega por ID e filtra client-side (0 leituras extras).
        _loadFavorites(id);

      case AppPetFilter.myPublications:
        _loadMyPublications(id);
    }
  }

  // ── Carregamento por IDs (favoritos e minhas publicações) ────────

  Future<void> _loadFavorites(int id) {
    final ids = FavoritesService.instance.current.toList();
    return _loadPetsByIds(
      ids,
      id,
      onOrphansCleanedUp: (uid, pets) =>
          FavoritesService.instance.cleanOrphans(uid, pets.map((p) => p.id)),
    );
  }

  Future<void> _loadMyPublications(int id) {
    final ids = MyPublicationsService.instance.current.toList();
    return _loadPetsByIds(
      ids,
      id,
      onOrphansCleanedUp: (uid, pets) => MyPublicationsService.instance
          .cleanOrphans(uid, pets.map((p) => p.id)),
    );
  }

  /// Carrega os pets por uma lista de IDs (sem paginação) e aplica a
  /// busca client-side quando há um termo digitado.
  Future<void> _loadPetsByIds(
    List<String> ids,
    int id, {
    required Future<void> Function(String uid, List<Pet> pets)
        onOrphansCleanedUp,
  }) async {
    if (ids.isEmpty) {
      _finishEmpty(id);
      return;
    }

    try {
      final pets = await PetService.instance.getPetsByIds(ids);
      if (!mounted || id != _loadId) return;

      final authUser = AuthService.instance.currentUser;
      if (authUser != null) {
        await onOrphansCleanedUp(authUser.uid, pets);
      }
      if (!mounted || id != _loadId) return;

      setState(() {
        _items = _applyLocalFilters(pets);
        _isLoading = false;
      });
    } on Exception catch (e, st) {
      _onLoadError(id, e, st);
    }
  }

  /// Filtra uma lista de pets já carregada pelo termo digitado,
  /// buscando por palavras do nome ou da descrição (insensível a
  /// maiúsculas e acentos). Equivale ao filtro dos favoritos.
  List<Pet> _filterBySearch(List<Pet> pets, String searchQuery) {
    final term = searchQuery.trim();
    return pets.where((p) {
      return containsTokens(p.name, term) ||
          containsTokens(p.description ?? '', term);
    }).toList();
  }

  /// Autoridade final do resultado: aplica a busca (quando há termo)
  /// e o AND exato por categoria dos filtros às páginas recebidas.
  List<Pet> _applyLocalFilters(List<Pet> pets) {
    var result = pets;
    if (_isSearching) {
      result = _filterBySearch(result, widget.searchQuery);
    }
    final options = _activeFilterOptions;
    if (options.isNotEmpty) {
      result = result.where((p) => petMatchesFilters(p, options)).toList();
    }
    return result;
  }

  // ── Recepção de resultados ────────────────────────────────────────

  void _onFeedPage(int id, PetsPage page) {
    if (!mounted || id != _loadId) return;
    setState(() {
      _items = _applyLocalFilters(page.pets);
      _lastDoc = page.lastDoc;
      _hasMore = page.hasMore;
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  void _onSearchResult(int id, List<Pet> pets) {
    if (!mounted || id != _loadId) return;
    setState(() {
      _items = _applyLocalFilters(pets);
      _isLoading = false;
    });
  }

  void _finishEmpty(int id) {
    if (!mounted || id != _loadId) return;
    setState(() {
      _items = [];
      _hasMore = false;
      _isLoading = false;
    });
  }

  void _onLoadError(int id, Object error, StackTrace stackTrace) {
    if (!mounted || id != _loadId) return;
    debugPrint(
      '[WGResponsivePetGrid] Erro ao carregar pets: $error\n$stackTrace',
    );
    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  // ── Paginação (rolagem) ──────────────────────────────────────────

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isSearching || _lastDoc == null) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final id = _loadId;
    _isLoadingMore = true;
    setState(() {});

    try {
      final PetsPage page;
      switch (widget.filter) {
        case AppPetFilter.all:
          final tags = _prefilterTags;
          page = tags != null
              ? await PetService.instance
                  .getFilteredNextPage(tags, _lastDoc!)
              : await PetService.instance.getNextPage(_lastDoc!);
        case AppPetFilter.myPublications:
        case AppPetFilter.favorites:
          return;
      }

      if (!mounted || id != _loadId) return;
      setState(() {
        _items = _mergeDeduplicated(_items, page.pets);
        _lastDoc = page.lastDoc;
        _hasMore = page.hasMore;
        _isLoadingMore = false;
      });
    } catch (e, st) {
      if (mounted && id == _loadId) {
        debugPrint('[WGResponsivePetGrid] Erro ao carregar mais pets: $e\n$st');
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  List<Pet> _mergeDeduplicated(List<Pet> current, List<Pet> next) {
    final seen = <String>{};
    final merged = <Pet>[];
    for (final pet in [...current, ...next]) {
      if (seen.add(pet.id)) {
        merged.add(pet);
      }
    }
    return merged;
  }

  /// Recarrega os dados (chamado pelas telas via pull-to-refresh).
  Future<void> reload() async {
    _setup();
  }

  // ── UI ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      if (widget.emptyBuilder != null) {
        return widget.emptyBuilder!(context);
      }
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 320
            ? 1
            : width < 700
            ? 2
            : 3;
        final childAspectRatio = width < 320
            ? 0.84
            : width < 700
            ? 0.68
            : 0.74;

        return Padding(
          padding:
              widget.padding ??
              EdgeInsets.symmetric(
                horizontal: width < 320 ? 10 : 14,
                vertical: width < 320 ? 10 : 16,
              ),
          child: CustomScrollView(
            controller: _scrollController,
            physics: widget.physics,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: widget.topSliverPadding,
                  bottom: 8,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: width < 320 ? 8 : 12,
                    mainAxisSpacing: width < 320 ? 8 : 12,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return widget.itemBuilder(context, _items[index]);
                  }, childCount: _items.length),
                ),
              ),
              if (_isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(strokeWidth: 2.6),
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: widget.bottomPadding)),
            ],
          ),
        );
      },
    );
  }
}
