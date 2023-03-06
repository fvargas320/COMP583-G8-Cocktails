import 'dart:convert';

import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:page_transition/page_transition.dart';

import '../CocktailPages/cocktail_card_page.dart';
import '../CocktailPages/grid_cocktails_page.dart';

class UserHomepage extends StatefulWidget {
  const UserHomepage({Key? key}) : super(key: key);

  @override
  State<UserHomepage> createState() => _UserHomepageState();
}

class _UserHomepageState extends State<UserHomepage>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;

  late AnimationController _controller;

  List<Cocktail> cocktails = [];

  Future getCocktails(String searchTerm) async {
    var response = await http.get(Uri.http(
        "thecocktaildb.com", "/api/json/v1/1/search.php", {"s": searchTerm}));
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          backgroundColor: Colors.grey.shade900,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Text(
                'Welcome,  ${user?.email}',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
//Popular Cocktails
              FutureBuilder(
                  future: getCocktails("margarita"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Popular Cocktails",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.fade,
                                              child: GridCocktails(
                                                  cocktail_list: cocktails)));
                                    },
                                    child: Text(
                                      "View All",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.redAccent),
                                    ),
                                  ),
                                ]),
                          ),
                          Container(
                            height: 400,
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              padding: EdgeInsets.all(14),
                              scrollDirection: Axis.horizontal,
                              itemCount: cocktails.length,
                              //itemBuilder: (context, index) => buildCard(),
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: buildCard(index),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
              SizedBox(
                height: 10,
              ),
              FutureBuilder(
                  future: getCocktails("martini"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "New Cocktails",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.fade,
                                              child: GridCocktails(
                                                  cocktail_list: cocktails)));
                                    },
                                    child: Text(
                                      "View All",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.redAccent),
                                    ),
                                  ),
                                ]),
                          ),
                          Container(
                            height: 400,
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              padding: EdgeInsets.all(14),
                              scrollDirection: Axis.horizontal,
                              itemCount: cocktails.length,
                              //itemBuilder: (context, index) => buildCard(),
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: buildCard(index),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ],
          ),
        ),
      );

  Widget buildCard(int index) => Container(
        decoration: BoxDecoration(
            //border: Border.all(color: Colors.blue),
            //color: Colors.blue,
            borderRadius: BorderRadius.circular(20)),
        //height: 200,

        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Material(
                  child: Ink.image(
                    image: NetworkImage(cocktails[index].strDrinkThumb),
                    fit: BoxFit.cover,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: CocktailCardPage(
                                    cocktail: cocktails[index])));
                      },
                    ),
                  ),
                ),
              ),
            ), //Pic
            // FittedBox(
            //   fit: BoxFit.fitWidth,
            //   child: Row(
            //     //crossAxisAlignment: CrossAxisAlignment.stretch,
            //     mainAxisAlignment: MainAxisAlignment.center,
            //
            //     children: [
            //       //Icon(Icons.local_drink),
            //       Container(
            //         child: Image.asset('assets/icons/bottle.png'),
            //       ),
            //       Text(
            //         "Tequila",
            //         style: TextStyle(color: Colors.redAccent, fontSize: 14),
            //       ),
            //
            //       Icon(Icons.fastfood),
            //       Text(
            //         "Flavor",
            //         style: TextStyle(color: Colors.red, fontSize: 14),
            //       ),
            //       SizedBox(
            //         width: 15,
            //       ),
            //
            //       Container(
            //         child: Image.asset('assets/icons/flex.png'),
            //       ),
            //       Text(
            //         "Weak",
            //         style: TextStyle(color: Colors.red, fontSize: 14),
            //       ),
            //       SizedBox(
            //         width: 15,
            //       ),
            //     ],
            //   ),
            // ), //Icons
            Text(
              cocktails[index].strDrink,
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87),
            ), //Cocktail Name
          ],
        ),
      );
}
