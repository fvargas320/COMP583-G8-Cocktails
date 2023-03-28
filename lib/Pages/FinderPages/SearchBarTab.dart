import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../data_model/HitsPage.dart';
import '../../data_model/Product.dart';
import '../../data_model/SearchMetadata.dart';

class SearchBarTab extends StatefulWidget {
  const SearchBarTab({Key? key}) : super(key: key);

  @override
  State<SearchBarTab> createState() => _SearchBarTabState();
}

class _SearchBarTabState extends State<SearchBarTab> {
  final _productsSearcher = HitsSearcher(
      applicationID: 'latency',
      apiKey: '927c3fe76d4b52c5a2912973f35a3077',
      indexName: 'STAGING_native_ecom_demo_products');

  final _searchTextController = TextEditingController();
  final PagingController<int, Product> _pagingController =
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
    }).onError((error) => _pagingController.error = error);
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

  Widget _hits(BuildContext context) => PagedListView<int, Product>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Product>(
          noItemsFoundIndicatorBuilder: (_) => const Center(
                child: Text('No results found'),
              ),
          itemBuilder: (_, item, __) => Container(
                color: Colors.white,
                height: 80,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    SizedBox(width: 50, child: Image.network(item.image)),
                    const SizedBox(width: 20),
                    Expanded(child: Text(item.name))
                  ],
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
