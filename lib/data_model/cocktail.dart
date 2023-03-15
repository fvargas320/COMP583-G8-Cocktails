import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

Cocktail cocktailFromJson(String str) => Cocktail.fromJson(json.decode(str));

String cocktailToJson(Cocktail data) => json.encode(data.toJson());

class Cocktail {
  final String cocktailID;
  final String strCocktailName;
  final String strDescription;
  final String strIngredients;
  final String strPreparation;
  final String strGarnish;
  final String strImageURL;
  final String strCategory;
  final String strCategories;
  final String strDetailedFlavors;
  final String strRim;
  final String strStrength;
  final String strMixers;
  final String strMainFlavor;

  Cocktail({
    required this.cocktailID,
    required this.strCocktailName,
    required this.strDescription,
    required this.strIngredients,
    required this.strPreparation,
    required this.strGarnish,
    required this.strImageURL,
    required this.strCategory,
    required this.strCategories,
    required this.strDetailedFlavors,
    required this.strRim,
    required this.strStrength,
    required this.strMixers,
    required this.strMainFlavor,
  });

  factory Cocktail.fromJson(Map<String, dynamic> json) => Cocktail(
        cocktailID: json["Cocktail_ID"],
        strCocktailName: json["Cocktail_Name"],
        strDescription: json["Description"],
        strIngredients: json["Ingredients"],
        strPreparation: json["Preparation"],
        strGarnish: json["Garnish"] ?? "None",
        strImageURL: json["Image_url"],
        strCategory: json["Category"],
        strCategories: json['Categories'],
        strDetailedFlavors: json["DetailedFlavors"] ?? "None",
        strRim: json["Rim"] ?? "None",
        strStrength: json["Strength"],
        strMixers: json["Mixers"] ?? "None",
        strMainFlavor: json["Main_Flavor"],
      );

  Map<String, dynamic> toJson() => {
        "Cocktail_ID": cocktailID,
        "Cocktail_Name": strCocktailName,
        "Description": strDescription,
        "Ingredients": strIngredients,
        "Preparation": strPreparation,
        "Garnish": strGarnish,
        "Image_url": strImageURL,
        "Category": strCategory,
        'Categories': strCategories,
        "DetailedFlavors": strDetailedFlavors,
        "Rim": strRim,
        "Strength": strStrength,
        "Mixers": strMixers,
        "Main_Flavor": strMainFlavor,
      };

  factory Cocktail.fromFirestore(Map<String, dynamic> snapshot) {
    final data = snapshot;
    return Cocktail(
      cocktailID: data["Cocktail_ID"],
      strCocktailName: data["Cocktail_Name"],
      strDescription: data["Description"],
      strIngredients: data["Ingredients"],
      strPreparation: data["Preparation"],
      strGarnish: data["Garnish"] ?? "None",
      strImageURL: data["Image_url"],
      strCategory: data["Category"],
      strCategories: data['Categories'],
      strDetailedFlavors: data["DetailedFlavors"] ?? "None",
      strRim: data["Rim"] ?? "None",
      strStrength: data["Strength"],
      strMixers: data["Mixers"] ?? "None",
      strMainFlavor: data["Main_Flavor"],
    );
  }

  factory Cocktail.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Cocktail(
      cocktailID: data?["Cocktail_ID"],
      strCocktailName: data?["Cocktail_Name"],
      strDescription: data?["Description"],
      strIngredients: data?["Ingredients"],
      strPreparation: data?["Preparation"],
      strGarnish: data?["Garnish"] ?? "None",
      strImageURL: data?["Image_url"],
      strCategory: data?["Category"],
      strCategories: data?['Categories'],
      strDetailedFlavors: data?["DetailedFlavors"] ?? "None",
      strRim: data?["Rim"] ?? "None",
      strStrength: data?["Strength"],
      strMixers: data?["Mixers"] ?? "None",
      strMainFlavor: data?["Main_Flavor"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (cocktailID != null) "Cocktail_ID": cocktailID,
      if (strCocktailName != null) "Cocktail_Name": strCocktailName,
      if (strDescription != null) "Description": strDescription,
      if (strIngredients != null) "Ingredients": strIngredients,
      if (strPreparation != null) "Preparation": strPreparation,
      if (strGarnish != null) "Garnish": strGarnish,
      if (strImageURL != null) "Image_url": strDescription,
      if (strCategory != null) "Category": strIngredients,
      if (strCategories != null) "Categories": strPreparation,
      if (strDetailedFlavors != null) "DetailedFlavors": strGarnish,
      if (strRim != null) "Rim": strGarnish,
      if (strStrength != null) "Strength": strDescription,
      if (strMixers != null) "Mixers": strIngredients,
      if (strMainFlavor != null) "Main_Flavor": strPreparation,
    };
  }
}
