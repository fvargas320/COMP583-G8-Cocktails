import 'dart:convert';

import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserHomepage extends StatefulWidget {
  const UserHomepage({Key? key}) : super(key: key);

  @override
  State<UserHomepage> createState() => _UserHomepageState();
}

class _UserHomepageState extends State<UserHomepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<Cocktail> cocktails = [];

  Future getCocktails() async {
    var response = await http.get(Uri.http(
        "thecocktaildb.com", "/api/json/v1/1/search.php", {"s": "margarita"}));
    var jsonData = jsonDecode(response.body);

    cocktails = [];

    for (var each_cocktail in jsonData["drinks"]) {
      final cocktail = Cocktail(
        idDrink: each_cocktail["idDrink"],
        strDrink: each_cocktail["strDrink"],
        strInstructions: each_cocktail["strInstructions"],
        strDrinkThumb: each_cocktail["strDrinkThumb"],
        strIngredient1: each_cocktail["strIngredient1"],
        strMeasure1: each_cocktail["strMeasure1"],
      );
      cocktails.add(cocktail);
    }
    print(cocktails.length);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getCocktails();
    // return const Scaffold(
    //   body: Center(
    //       child: Text(
    //     "User HomePage",
    //     style: TextStyle(
    //       color: Colors.black,
    //       fontWeight: FontWeight.bold,
    //       fontSize: 25,
    //     ),
    //   )),
    // );

    return Scaffold(
      body: FutureBuilder(
        future: getCocktails(),
        builder: (context, snapshot) {
          //done loading?
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: cocktails.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      title: Text(cocktails[index].strDrink),
                      subtitle: Text(cocktails[index].strInstructions),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
