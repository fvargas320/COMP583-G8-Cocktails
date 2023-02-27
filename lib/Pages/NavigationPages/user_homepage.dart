import 'dart:convert';

import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:page_transition/page_transition.dart';

import '../CocktailPages/cocktail_card_page.dart';

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

  void navigateCardPage(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CocktailCardPage(
                  cocktail: cocktails[index],
                )));
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

    return Scaffold(
      body: FutureBuilder(
        future: getCocktails(),
        builder: (context, snapshot) {
          //done loading?
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              // gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              //   maxCrossAxisExtent: 220,
              //   childAspectRatio: 3 / 2,
              //   crossAxisSpacing: 20,
              //   mainAxisSpacing: 20,
              // ),
              itemCount: cocktails.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: CocktailCardPage(
                                    cocktail: cocktails[index])));
                      },
                      child: Column(
                        children: [
                          Image.network(
                            cocktails[index].strDrinkThumb,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.local_drink),
                                Text(
                                  "Tequila",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Icon(Icons.fastfood),
                                Text(
                                  "Flavor",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Icon(Icons.power),
                                Text(
                                  "Weak",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Icon(Icons.list_alt_rounded),
                                Text(
                                  "2 Ingredients",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            title: Center(
                              child: Text(
                                cocktails[index].strDrink,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            //subtitle: Text(cocktails[index].strInstructions),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: CocktailCardPage(
                                          cocktail: cocktails[index])));
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                LikeButton(
                                  likeCount: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
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
