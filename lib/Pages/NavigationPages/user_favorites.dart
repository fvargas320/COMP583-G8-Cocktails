import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Cocktail> _favoriteCocktails = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
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
    // Get the current user ID
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Remove the cocktail from the user's favorites collection
    await FirebaseFirestore.instance
        .collection('Favorite')
        .doc(userId)
        .collection('FavoriteCocktails')
        .doc(cocktail.cocktailID)
        .delete();

    setState(() {
      isLiked = false;
      _fetchFavorites();
    });

    // Show a message pop-up to indicate that the cocktail has been deleted
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$cocktail dismissed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.grey.shade900,
        elevation: 5,
      ),
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
                        onPressed: (context) => _removeFromFavorites(cocktail),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Image.network(
                      cocktail.strImageURL,
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
                );
              },
            ),
    );
  }
}
