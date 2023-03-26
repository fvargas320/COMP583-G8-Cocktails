import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';

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
                return ListTile(
                  leading: Image.network(cocktail.strImageURL),
                  title: Text(cocktail.strCocktailName ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CocktailCardPage(cocktail: cocktail),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
