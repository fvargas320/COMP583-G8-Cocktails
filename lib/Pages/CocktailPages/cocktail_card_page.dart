import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class CocktailCardPage extends StatefulWidget {
  final Cocktail cocktail;

  CocktailCardPage({Key? key, required this.cocktail}) : super(key: key);

  @override
  _CocktailCardPageState createState() => _CocktailCardPageState();
}

class _CocktailCardPageState extends State<CocktailCardPage> {
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  bool isLiked = false;

  void _addToFavorites(Cocktail cocktail) async {
    // Get the current user ID
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Add the cocktail to the user's favorites collection
    await FirebaseFirestore.instance
        .collection('Favorite')
        .doc(userId)
        .collection('FavoriteCocktails')
        .doc(cocktail.cocktailID)
        .set({
      "Cocktail_ID": cocktail.cocktailID,
      "Cocktail_Name": cocktail.strCocktailName,
      "Description": cocktail.strDescription,
      "Ingredients": cocktail.strIngredients,
      "Preparation": cocktail.strPreparation,
      "Garnish": cocktail.strGarnish,
      "Image_url": cocktail.strImageURL,
      "Category": cocktail.strCategory,
      'Categories': cocktail.strCategories,
      "DetailedFlavors": cocktail.strDetailedFlavors,
      "Rim": cocktail.strRim,
      "Strength": cocktail.strStrength,
      "Mixers": cocktail.strMixers,
      "Main_Flavor": cocktail.strMainFlavor,
      // Add any other cocktail information you want to save
    });

    setState(() {
      isLiked = true;
    });
  }

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
    });
  }

  Future<bool> addToFavoritesCallback(bool isLiked) async {
    if (isLiked) {
      _removeFromFavorites(widget.cocktail);
    } else {
      _addToFavorites(widget.cocktail);
    }
    return !isLiked;
  }

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  void _checkIfLiked() async {
    // Get the current user ID
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Check if the cocktail is in the user's favorites collection
    final cocktailDoc = await FirebaseFirestore.instance
        .collection('Favorite')
        .doc(userId)
        .collection('FavoriteCocktails')
        .doc(widget.cocktail.cocktailID)
        .get();

    if (cocktailDoc.exists) {
      setState(() {
        isLiked = true;
      });
    }
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
          Image.network(
            widget.cocktail.strImageURL,
            height: 400,
            width: 400,
            //fit: BoxFit.fitHeight,
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
              const SizedBox(
                width: 30,
              ),
              // LikeButton(
              //   onTap: addToFavoritesCallback,
              //   likeBuilder: (isLiked) {
              //     return Icon(
              //       Icons.add_circle,
              //       color: Colors.grey.shade500,
              //       size: 30,
              //     );
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
