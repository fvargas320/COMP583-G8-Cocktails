import 'dart:convert';

import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_model/getCocktailData.dart';
import '../CocktailPages/cocktail_card_page.dart';
import '../CocktailPages/grid_cocktails_page.dart';

class UserHomepage extends StatefulWidget {
  const UserHomepage({Key? key}) : super(key: key);

  @override
  State<UserHomepage> createState() => _UserHomepageState();
}

class _UserHomepageState extends State<UserHomepage>
    with SingleTickerProviderStateMixin {
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference cocktailss =
      FirebaseFirestore.instance.collection('cocktails');

  late AnimationController _controller;

  List<Cocktail> cocktails = [];

  List<Cocktail> listOfPartyCocktails = [];
  List<Cocktail> listOfFruityCocktails = [];
  List<Cocktail> listOfQuickEasyCocktails = [];

  //List<Cocktail> listOfCocktailss = [];

  Future getCocktailsFirestores() async {
    var fruitCocktails = await FirebaseFirestore.instance
        .collection('cocktails')
        .where("Main_Flavor", isEqualTo: "Fruity")
        .get();

    cocktailRecords(fruitCocktails, listOfFruityCocktails);
  }

  Future getPartyFavoriteCocktails() async {
    var cocktails = await FirebaseFirestore.instance
        .collection('cocktails')
        .where("Categories", isEqualTo: "Party Favorites & Crowd Pleasers")
        .get();
    cocktailRecords(cocktails, listOfPartyCocktails);
  }

  Future getQuickAndEasyCocktails() async {
    var cocktails = await FirebaseFirestore.instance
        .collection('cocktails')
        .where("Categories", isEqualTo: "Quick & Easy Cocktails")
        .get();
    cocktailRecords(cocktails, listOfQuickEasyCocktails);
  }

  cocktailRecords(QuerySnapshot<Map<String, dynamic>> cocktails,
      List<Cocktail> listOfCocktailss) {
    //listOfCocktailss = [];
    //listOfCocktailss = [];

    print(cocktails.docs.length);
    //print(cocktails.docs.last);
    //print(cocktails.docs[1].data());

    for (var i = 0; i < cocktails.docs.length; i++) {
      //print(cocktails.docs[i].data());
      var data = cocktails.docs[i].data();
      listOfCocktailss.add(Cocktail(
        cocktailID: data["Cocktail_ID"].toString(),
        strCocktailName: data["Cocktail_Name"],
        strDescription: data["Description"],
        strIngredients: data["Ingredients"],
        strPreparation: data["Preparation"],
        strGarnish: data["Garnish"] ?? "None",
        strImageURL: data["Image_url"],
        strCategory: data["Category"] ?? "None",
        strCategories: data['Categories'] ?? "None",
        strDetailedFlavors: data["DetailedFlavors"] ?? "None",
        strRim: data["Rim"] ?? "None",
        strStrength: data["Strength"],
        strMixers: data["Mixers"] ?? "None",
        strMainFlavor: data["Main_Flavor"] ?? "None",
      ));

      print(listOfCocktailss.length);
    }

    // var _list = cocktails.docs
    //     .map((data) => Cocktail(
    //           cocktailID: data.id.toString(),
    //           strCocktailName: data["Cocktail_Name"],
    //           strDescription: data["Description"],
    //           strIngredients: data["Ingredients"],
    //           strPreparation: data["Preparation"],
    //           strGarnish: data["Garnish"] ?? "None",
    //           strImageURL: data["Image_url"],
    //           strCategory: data["Category"],
    //           strCategories: data['Categories'],
    //           strDetailedFlavors: data["DetailedFlavors"] ?? "None",
    //           strRim: data["Rim"] ?? "None",
    //           strStrength: data["Strength"],
    //           strMixers: data["Mixers"] ?? "None",
    //           strMainFlavor: data["Main_Flavor"],
    //         ))
    //     .toList();

    // setState(() {
    //   listOfCocktails;
    // });
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
    getCocktailsFirestores();
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
              FutureBuilder(
                  future: getQuickAndEasyCocktails(),
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
                                    "Quick & Easy Cocktails",
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
                                                  cocktail_list:
                                                      listOfQuickEasyCocktails)));
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
                                      crossAxisCount: 1),
                              padding: EdgeInsets.all(14),
                              scrollDirection: Axis.horizontal,
                              itemCount: 12, //change to cocktails.length
                              //itemBuilder: (context, index) => buildCard(),
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child:
                                    buildCard(listOfQuickEasyCocktails[index]),
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
                  future: getPartyFavoriteCocktails(),
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
                                    "Party Favorites & Crowd Pleasers",
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
                                                  cocktail_list:
                                                      listOfPartyCocktails)));
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
                              itemCount: 12, //change to cocktails.length
                              //itemBuilder: (context, index) => buildCard(),
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: buildCard(listOfPartyCocktails[index]),
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
//Popular Cocktails
              FutureBuilder(
                  future: getCocktailsFirestores(),
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
                                    "Fruity Cocktails",
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
                                                  cocktail_list:
                                                      listOfFruityCocktails)));
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
                              itemCount: 12, //change to cocktails.length
                              //itemBuilder: (context, index) => buildCard(),
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: buildCard(listOfFruityCocktails[index]),
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
            ],
          ),
        ),
      );

  Widget buildCard(Cocktail cocktailId) => Container(
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
                    image: NetworkImage(cocktailId.strImageURL),
                    fit: BoxFit.cover,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: CocktailCardPage(cocktail: cocktailId)));
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
              cocktailId.strCocktailName,
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
