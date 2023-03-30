import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
      apiKey: '8e08827d067077ab2ce141b74e215b58',
      indexName: 'Cocktails');

  final _searchTextController = TextEditingController();
  final PagingController<int, Cocktail> _pagingController =
      PagingController(firstPageKey: 0);

  Stream<SearchMetadata> get _searchMetadata =>
      _productsSearcher.responses.map(SearchMetadata.fromResponse);

  Stream<HitsPage> get _searchPage =>
      _productsSearcher.responses.map(HitsPage.fromResponse);

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
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _productsSearcher.dispose();
    _pagingController.dispose();
    super.dispose();
  }

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
                        onPressed: (context) => print("HI"),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        icon: Icons.favorite,
                        label: 'Favorite',
                      ),
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 1,
                        onPressed: (context) => print("HI"),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                height: 44,
                child: TextField(
                  controller: _searchTextController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter a search term',
                    prefixIcon: Icon(Icons.search),
                  ),
                )),
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
