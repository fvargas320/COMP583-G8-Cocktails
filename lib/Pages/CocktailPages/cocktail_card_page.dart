import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:like_button/like_button.dart';
import '../../Services/favorites_service.dart';
import '../../Services/userLists_service.dart';

class CocktailCardPage extends StatefulWidget {
  final Cocktail cocktail;

  CocktailCardPage({Key? key, required this.cocktail}) : super(key: key);

  @override
  _CocktailCardPageState createState() => _CocktailCardPageState();
}

class _CocktailCardPageState extends State<CocktailCardPage> {
  final _listNameController = TextEditingController();
  final _listDescriptionController = TextEditingController();
  var selectedCocktail;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  void _checkIfLiked() async {
    final isFavorite =
        await FavoritesService.checkIfLiked(widget.cocktail.cocktailID);

    setState(() {
      isLiked = isFavorite;
    });
  }

  Future<bool> addToFavoritesCallback(bool isLiked) async {
    if (isLiked) {
      FavoritesService.removeFromFavorites(widget.cocktail);
    } else {
      FavoritesService.addToFavorites(widget.cocktail);
    }
    return !isLiked;
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          title: Text(
            "${widget.cocktail.strCocktailName} ${widget.cocktail.cocktailID}",
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          backgroundColor: Colors.grey.shade900,
          elevation: 5,
        ),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          const SizedBox(
            height: 10,
          ),
          CachedNetworkImage(
            imageUrl: widget.cocktail.strImageURL,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/2748/2748558.png"),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.cocktail.strCocktailName,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              const Text(
                "Description",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  widget.cocktail.strDescription,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const Text(
                "Ingredients",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.cocktail.strIngredients.split(",").join("\n"),
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "Garnish",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.cocktail.strGarnish,
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "Rim",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.cocktail.strRim,
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              const Text(
                "Recipe Instructions",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  widget.cocktail.strPreparation.split(" ,").join("\n"),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LikeButton(
                isLiked: isLiked,
                onTap: addToFavoritesCallback,
              ),
              Text("Add to Favorites"),
              LikeButton(
                circleColor: CircleColor(
                    start: Color(0xff00ddff), end: Color(0xff0099cc)),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: Color(0xff33b5e5),
                  dotSecondaryColor: Color(0xff0099cc),
                ),
                likeBuilder: (bool isLiked) {
                  return Icon(
                    Icons.add_circle,
                    color: isLiked ? Colors.deepPurpleAccent : Colors.grey,
                  );
                },
                // onTap: (context) {
                //   setState(() {
                //     selectedCocktail = widget.cocktail;
                //   });
                //   _showListDialog();
                // },
              ),
              Text("Add to List"),
            ],
          ),
        ],
      ),
    );
  }
}
