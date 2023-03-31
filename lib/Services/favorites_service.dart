import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  static Future<void> addToFavorites(Cocktail cocktail) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
    });
  }

  static Future<void> removeFromFavorites(Cocktail cocktail) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    await FirebaseFirestore.instance
        .collection('Favorite')
        .doc(userId)
        .collection('FavoriteCocktails')
        .doc(cocktail.cocktailID)
        .delete();
  }

  static Future<bool> checkIfLiked(String cocktailID) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final cocktailDoc = await FirebaseFirestore.instance
        .collection('Favorite')
        .doc(userId)
        .collection('FavoriteCocktails')
        .doc(cocktailID)
        .get();

    return cocktailDoc.exists;
  }
}
