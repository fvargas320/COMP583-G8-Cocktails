import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drinkly_cocktails/Features/AddToLists.dart';
import 'package:drinkly_cocktails/Services/favorites_service.dart';
import 'package:drinkly_cocktails/Services/userLists_service.dart';
import 'package:drinkly_cocktails/data_model/UserLists.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../CocktailPages/cocktail_card_page.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  final _listNameController = TextEditingController();
  final _listDescriptionController = TextEditingController();

  List<Cocktail> _favoriteCocktails = [];

  var isChecked1 = false;
  var isChecked = false;

  var selectedCocktail;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  @override
  void dispose() {
    //Implement dispose
    _listNameController.dispose();
    _listDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchFavorites() async {
    final favoritesSnapshot = await db
        .collection('Favorite')
        .doc(user?.uid)
        .collection('FavoriteCocktails')
        .get();
    final favoriteCocktails = <Cocktail>[];
    for (final doc in favoritesSnapshot.docs) {
      final data = doc.data();
      if (data == null) continue;
      final cocktail = Cocktail.fromMap(data as Map<String, dynamic>);
      favoriteCocktails.add(cocktail);
    }

    setState(() {
      _favoriteCocktails = favoriteCocktails;
    });
  }

  bool isLiked = true;
  void _removeFromFavorites(Cocktail cocktail) async {
    FavoritesService.removeFromFavorites(cocktail);

    setState(() {
      //isLiked = false;
      _fetchFavorites();
    });

    var cocktail_ID = cocktail.cocktailID;
    // Show a message pop-up to indicate that the cocktail has been deleted
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed Cocktail: $cocktail_ID')));
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: _favoriteCocktails.isEmpty
          ? Center(child: Text('No favorite cocktails yet.'))
          : ListView.builder(
              itemCount: _favoriteCocktails.length,
              itemBuilder: (BuildContext context, int index) {
                final cocktail = _favoriteCocktails[index];
                return Slidable(
                  // Specify a key if the Slidable is dismissible.
                  key: const ValueKey(0),

                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 1,
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        onPressed: (context) => _removeFromFavorites(cocktail),
                        label: 'Remove',
                      ),
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 1,
                        // onPressed: (context) => _showListDialog(),
                        onPressed: (context) {
                          setState(() {
                            selectedCocktail = cocktail;
                          });
                          _showListDialog();
                          print(cocktail.cocktailID);
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        //icon: Icons.add_circle,
                        icon: Icons.add_circle,
                        label: 'Lists',
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity, // or specify a fixed width
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: cocktail.strImageURL,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CachedNetworkImage(
                            imageUrl:
                                "https://cdn-icons-png.flaticon.com/512/2748/2748558.png"),
                      ),
                      title: Text(cocktail.strCocktailName ?? ''),
                      subtitle: Text(
                        "${cocktail.strMainFlavor} Flavor, ${cocktail.strCategories}",
                        overflow: TextOverflow.fade,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CocktailCardPage(cocktail: cocktail),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
