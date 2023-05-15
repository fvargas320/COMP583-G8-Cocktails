import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../Services/favorites_service.dart';
import '../../Services/userLists_service.dart';
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

  final _listNameController = TextEditingController();
  final _listDescriptionController = TextEditingController();
  var selectedCocktail;

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
    final updatedIsLiked = !isLiked; // Invert the isLiked value

    if (updatedIsLiked) {
      await FavoritesService.addToFavorites(cocktail);
    } else {
      await FavoritesService.removeFromFavorites(cocktail);
    }

    setState(() {
      isLiked = updatedIsLiked;
    });

    return updatedIsLiked;
  }

  Future<void> _showCreateListDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Creating New List'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please fill in data for list.'),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
                TextField(
                  controller: _listNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Enter a List Name',
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
                TextField(
                  controller: _listDescriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a description for list',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Back'),
              onPressed: () {
                Navigator.of(context).pop();
                _showListDialog();
              },
            ),
            TextButton(
              child: const Text('Create List'),
              onPressed: () {
                //Call Create List
                createAList(_listNameController.text.trim(),
                    _listDescriptionController.text.trim());
                Navigator.of(context).pop();
                setState(() {
                  //isLiked = false;
                  _showListDialog();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showListDialog() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final listsSnapshot = await FirebaseFirestore.instance
        .collection("User Lists")
        .doc(userId)
        .collection("Lists")
        .get();

    var selectedLists = [];
    List<Widget> listTiles = [];

    for (var doc in listsSnapshot.docs) {
      final listName = doc.get("listName");
      final listDesc = doc.get("listDesc");
      bool isChecked = false;

      listTiles.add(Slidable(
        // Specify a key if the Slidable is dismissible.
        key: Key(doc.id),

        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              // An action can be bigger than the others.
              flex: 1,
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              onPressed: (context) => removeAList(listName),
              label: 'Remove',
            ),
          ],
        ),

        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return CheckboxListTile(
              key: Key(doc.id),
              title: Text(listName),
              subtitle: Text(listDesc),
              checkColor: Colors.white,
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                  if (isChecked == true) {
                    selectedLists.add(listName);
                  } else {
                    selectedLists.remove(listName);
                  }
                  print(isChecked);
                  print(selectedLists);
                });
              },
            );
          },
        ),
      ));
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to List'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Select a list to Add To..'),
                ...listTiles,
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
                Text('Want to add to a new list?'),
                TextButton(
                  child: const Text('Create a list'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showCreateListDialog();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Back'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                handlingMultipleSelections(selectedLists, selectedCocktail);
                //handlingAddingCocktail("popp", cocktail),
              },
            ),
          ],
        );
      },
    );
  }

  void handlingMultipleSelections(
      List<dynamic> selectedLists, Cocktail cocktail) {
    if (selectedLists.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Nothing selected'),
            content: Text('Please select a list to add the cocktail.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else if (selectedLists.length == 1) {
      for (var listName in selectedLists) {
        ListsService.addCocktailToList(listName, cocktail, context);
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Cocktail added to multiple lists'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      for (var listName in selectedLists) {
        ListsService.addCocktailToList(listName, cocktail, context);
      }
    }
  }

  Future<void> createAList(String listName, String listDescription) async {
    ListsService.createList(listName, listDescription, context);
  }

  Future<void> removeAList(String listName) async {
    ListsService.deleteEntireList(listName);
    Navigator.of(context).pop();

    setState(() {
      //isLiked = false;
      _showListDialog();
    });
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
                      FutureBuilder<bool>(
                          future: _checkIfLiked(item),
                          builder: (context, snapshot) {
                            bool isCocktailLiked;
                            isCocktailLiked = snapshot.data!;
                            return SlidableAction(
                              // An action can be bigger than the others.
                              flex: 1,
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              icon: isCocktailLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              onPressed: (context) => {
                                isCocktailLiked = snapshot.data!,
                                addToFavoritesCallback(isCocktailLiked!, item),
                              },

                              label: 'Favorite',
                            );
                          }),
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 1,
                        // onPressed: (context) => _showListDialog(),
                        onPressed: (context) {
                          setState(() {
                            selectedCocktail = item;
                          });
                          _showListDialog();
                          print(item.cocktailID);
                        },
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
