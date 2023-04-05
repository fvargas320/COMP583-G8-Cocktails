import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../Services/favorites_service.dart';
import '../../data_model/HitsPage.dart';
import '../../data_model/SearchMetadata.dart';
import '../CocktailPages/cocktail_card_page.dart';

class SearchBarTab extends StatefulWidget {
  const SearchBarTab({Key? key}) : super(key: key);

  @override
  State<SearchBarTab> createState() => _SearchBarTabState();
}

class _SearchBarTabState extends State<SearchBarTab> {
  final _productsSearcher = HitsSearcher(
      applicationID: 'HNELVCXNJF',
      apiKey: 'eadf52d2df93b72c6f7a543221712390',
      indexName: 'Cocktails');

  final _searchTextController = TextEditingController();
  final PagingController<int, Cocktail> _pagingController =
      PagingController(firstPageKey: 0);
  final _filterState = FilterState();
  final GlobalKey<ScaffoldState> _mainScaffoldKey = GlobalKey();

  late final _facetList = FacetList(
      searcher: _productsSearcher,
      filterState: _filterState,
      attribute: "Main_Flavor");

  Stream<SearchMetadata> get _searchMetadata =>
      _productsSearcher.responses.map(SearchMetadata.fromResponse);

  Stream<HitsPage> get _searchPage =>
      _productsSearcher.responses.map(HitsPage.fromResponse);

  bool isLiked = false;

  Future<bool> _checkIfLiked(Cocktail cocktail) async {
    final isFavorite = await FavoritesService.checkIfLiked(cocktail.cocktailID);

    setState(() {
      isLiked = isFavorite;
    });

    return isLiked;
  }

  Future<bool> addToFavoritesCallback(bool isLiked, Cocktail cocktail) async {
    _checkIfLiked(cocktail);
    //isLiked = _checkIfLiked(cocktail) as bool;
    if (isLiked) {
      FavoritesService.removeFromFavorites(cocktail);
    } else {
      FavoritesService.addToFavorites(cocktail);
    }
    setState(() {
      this.isLiked = !isLiked;
    });
    return !isLiked;
  }

  @override
  void initState() {
    super.initState();

    _searchTextController.addListener(
      () => _productsSearcher.applyState(
        (state) => state.copyWith(
          query: _searchTextController.text,
          page: 0,
        ),
      ),
    );
    _searchPage.listen((page) {
      if (page.pageKey == 0) {
        _pagingController.refresh();
      }
      _pagingController.appendPage(page.items, page.nextPageKey);
      print(page.items.length);
    }).onError((error) {
      print('Error in _searchPage stream: $error');
      _pagingController.error = error;
    });

    _pagingController.addPageRequestListener((pageKey) =>
        _productsSearcher.applyState((state) => state.copyWith(page: pageKey)));

    _productsSearcher.connectFilterState(_filterState);
    _filterState.filters.listen((_) => _pagingController.refresh());
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _productsSearcher.dispose();
    _pagingController.dispose();
    _filterState.dispose();
    _facetList.dispose();
    super.dispose();
  }

  Widget _filters(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Filters'),
          backgroundColor: Colors.black54,
        ),
        body: StreamBuilder<List<SelectableItem<Facet>>>(
            stream: _facetList.facets,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final selectableFacets = snapshot.data!;
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: selectableFacets.length,
                  itemBuilder: (_, index) {
                    final selectableFacet = selectableFacets[index];
                    return CheckboxListTile(
                      value: selectableFacet.isSelected,
                      title: Text(
                          "${selectableFacet.item.value} (${selectableFacet.item.count})"),
                      onChanged: (_) {
                        _facetList.toggle(selectableFacet.item.value);
                      },
                    );
                  });
            }),
      );

  Widget _hits(BuildContext context) => PagedListView<int, Cocktail>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Cocktail>(
          noItemsFoundIndicatorBuilder: (_) => const Center(
                child: Text('No cocktails found'),
              ),
          itemBuilder: (_, item, __) => Container(
                color: Colors.white,
                height: 100,
                padding: const EdgeInsets.all(8),
                child: Slidable(
                  key: const ValueKey(0),

                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 1,
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        onPressed: (context) => print("JH"),

                        label: 'Favorite',
                      ),
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 1,
                        onPressed: (context) => print("JH"),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        //icon: Icons.add_circle,
                        icon: Icons.add_circle,
                        label: 'Lists',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Image.network(
                      item.strImageURL,
                    ),
                    title: Text(item.strCocktailName ?? ''),
                    subtitle: Text(
                      "${item.strMainFlavor} Flavor, ${item.strCategories}",
                      overflow: TextOverflow.fade,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CocktailCardPage(cocktail: item),
                        ),
                      );
                    },
                  ),
                ),
              )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mainScaffoldKey,
      endDrawer: Drawer(
        child: _filters(context),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchTextController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter a search term',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _mainScaffoldKey.currentState?.openEndDrawer(),
                  icon: const Icon(Icons.filter_list_sharp),
                ),
              ],
            ),
            StreamBuilder<SearchMetadata>(
              stream: _searchMetadata,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${snapshot.data!.nbHits} matching cocktails'),
                );
              },
            ),
            Expanded(
              child: _hits(context),
            )
          ],
        ),
      ),
    );
  }
}
