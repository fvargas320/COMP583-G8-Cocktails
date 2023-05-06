import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Services/userLists_service.dart';
import '../../data_model/cocktail.dart';
import '../CocktailPages/cocktail_card_page.dart';

class ListsPage extends StatefulWidget {
  @override
  ListsPageWidget createState() => ListsPageWidget();
}

class ListsPageWidget extends State<ListsPage> {
  late List<String> listNames;

  @override
  void initState() {
    super.initState();
  }

  Future<List<List<Cocktail>>> getAllLists() async {
    listNames = await ListsService.getAllListNames();
    print(listNames);

    List<List<Cocktail>> lists = [];

    for (String listName in listNames) {
      print(listName);
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('User Lists')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Lists')
          .doc(listName)
          .get();

      List<String> cocktailIDs = List.from(snapshot.data()!['cocktailIDs']);
      print(cocktailIDs);

      List<Cocktail> cocktails = [];
      for (String cocktailID in cocktailIDs) {
        Cocktail cocktail = await getCocktailFromFirestore(cocktailID);
        cocktails.add(cocktail);
      }
      lists.add(cocktails);
    }
    print(lists);

    return lists;
  }

  Future<Cocktail> getCocktailFromFirestore(String cocktail_ID) async {
    Cocktail new_cocktail;

    int cocktailIDInt = int.parse(cocktail_ID);
    var cocktailByID = await FirebaseFirestore.instance
        .collection('cocktails')
        .where("Cocktail_ID", isEqualTo: cocktailIDInt)
        .get();

    new_cocktail = cocktailRecords(cocktailByID);
    return new_cocktail;
  }

  cocktailRecords(QuerySnapshot<Map<String, dynamic>> cocktailFirebase) {
    Cocktail cocktail;
    var data = cocktailFirebase.docs[0].data();
    cocktail = Cocktail(
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
      strAlcohols: data["Alcohols"] ?? "NONE",
    );

    return cocktail;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Cocktail>>>(
      future: getAllLists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data found.'));
        } else {
          List<List<Cocktail>> lists = snapshot.data!;
          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              List<Cocktail> cocktails = lists[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      '${listNames[index]} (${cocktails.length} cocktails)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: cocktails.length,
                    itemBuilder: (context, index) {
                      Cocktail cocktail = cocktails[index];
                      return ListTile(
                        leading: Image.network(
                          cocktail.strImageURL,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                        title: Text(cocktail.strCocktailName),
                        subtitle: Text(cocktail.strCategory),
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
                ],
              );
            },
          );
        }
      },
    );
  }
}
