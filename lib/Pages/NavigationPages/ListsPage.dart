import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drinkly_cocktails/Pages/CocktailPages/grid_cocktails_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:readmore/readmore.dart';

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

  Future<String> getListDescription(String listName) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('User Lists')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('Lists')
        .doc(listName)
        .get();

    String listDesc = snapshot.data()?['listDesc'];
    return listDesc ?? '';
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
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<List<Cocktail>>>(
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
                          child: Row(
                            children: [
                              Text(
                                '${listNames[index]} (Total: ${cocktails.length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Text('Edit'),
                                    value: 'edit',
                                  ),
                                  PopupMenuItem(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                    value: 'delete',
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    // handle edit menu option
                                  } else if (value == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Delete List'),
                                          content: Text(
                                              'Are you sure you want to delete this '
                                              'list? There is no way to restore it'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              onPressed: () {
                                                ListsService.deleteEntireList(
                                                    listNames[index]);
                                                Navigator.of(context).pop();
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: FutureBuilder<String>(
                            future: getListDescription(listNames[index]),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                );
                              } else {
                                return ReadMoreText(
                                  snapshot.data ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  trimLines: 2,
                                  colorClickableText: Colors.pink,
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: 'Show more',
                                  trimExpandedText: 'Show less',
                                  moreStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: min(3, cocktails.length),
                          itemBuilder: (context, innerIndex) {
                            Cocktail cocktail = cocktails[innerIndex];
                            return Slidable(
                              key: const ValueKey(0),
                              endActionPane: ActionPane(
                                motion: ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    flex: 1,
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    onPressed: (context) {
                                      ListsService.removeCocktailFromList(
                                          listNames[index], cocktail);
                                      setState(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Removed cocktail ${cocktail.cocktailID} from list (${listNames[index]})')));
                                    },
                                    label: 'Remove',
                                    icon: Icons.delete,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    cocktail.strImageURL,
                                  ),
                                ),
                                title: Text(
                                  cocktail.strCocktailName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  cocktail.strCategory,
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
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GridCocktails(
                                          cocktail_list: cocktails)),
                                );
                              },
                              child: Text('View all'),
                            )
                          ],
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
        Column(
          children: [
            Text(
              'Want to create a new list?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: () {
                // handle button press
              },
              child: Text(
                'New List',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
