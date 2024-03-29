import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Services/favorites_service.dart';
import '../../data_model/cocktail.dart';
import '../CocktailPages/cocktail_card_page.dart';

class RecommendationsTab {
  String _appId;
  String _apiKey;
  String _indexName;

  RecommendationsTab(this._appId, this._apiKey, this._indexName);

  Future<List<Map<String, dynamic>>> getRecommendations(
      String cocktail_ID) async {
    final url =
        'https://' + _appId + '-dsn.algolia.net/1/indexes/*/recommendations';
    final headers = {
      'Content-Type': 'application/json',
      'X-Algolia-API-Key': _apiKey,
      'X-Algolia-Application-Id': _appId
    };
    final body = {
      'requests': [
        {
          'indexName': _indexName,
          'model': 'related-products',
          'objectID': cocktail_ID,
          'threshold': 0,
          'maxRecommendations': 3,
        }
      ]
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(body));
    final responseBody = jsonDecode(response.body);

    final hits = responseBody['results'][0]['hits'];

    //List<Cocktail> recommended_Cocktails = [];
    List<Map<String, dynamic>> recommended_Cocktails = [];

    print("HITS FROM REC");
    print(hits);
    hits.forEach((hit) {
      recommended_Cocktails.add({
        'Cocktail_ID': hit?["Cocktail_ID"],
        'Cocktail_Name': hit?["Cocktail_Name"],
        'Description': hit?["Description"],
        'Ingredients': hit?["Ingredients"],
        'StrPreparation': hit?["Preparation"],
        'Garnish': hit?["Garnish"] ?? "None",
        'Image_url': hit?["Image_url"],
        'Category': hit?["Category"],
        'Categories': hit?['Categories'],
        'DetailedFlavors': hit?["DetailedFlavors"] ?? "None",
        'Rim': hit?["Rim"] ?? "None",
        'Strength': hit?["Strength"],
        'Mixers': hit?["Mixers"] ?? "None",
        'Main_Flavor': hit?["Main_Flavor"],
        'Alcohols': hit?["Alcohols"] ?? "None",
      });
    });

    return recommended_Cocktails;
  }
}

class AlgoliaRecommendationWidget extends StatefulWidget {
  @override
  _AlgoliaRecommendationWidgetState createState() =>
      _AlgoliaRecommendationWidgetState();
}

class _AlgoliaRecommendationWidgetState
    extends State<AlgoliaRecommendationWidget> {
  List<Cocktail> _recommendations = [];
  bool _isLoading = false;
  final _algoliaRecommend = RecommendationsTab(
      'HNELVCXNJF', 'eadf52d2df93b72c6f7a543221712390', 'Cocktails');
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  List<Cocktail> _favoriteCocktails = [];

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
      final cocktail = Cocktail.fromMap(data);
      favoriteCocktails.add(cocktail);
    }

    setState(() {
      _favoriteCocktails = favoriteCocktails;
    });
  }

  Future<List<Cocktail>> getRecommendationsFromCocktail(
      Cocktail cocktail) async {
    List<Cocktail> cocktailList = [];
    final results =
        await _algoliaRecommend.getRecommendations(cocktail.cocktailID);

    results.forEach((element) {
      cocktailList.add(Cocktail.fromMap(element));
    });

    List<Cocktail> finalCocktailList = [];

    if (results.length >= 5) {
      for (var i = 0; i < 5; i++) {
        var newCocktail = cocktailList[i];
        finalCocktailList.add(newCocktail);
      }
    } else {
      for (var i = 0; i < results.length; i++) {
        var newCocktail = cocktailList[i];
        finalCocktailList.add(newCocktail);
      }
    }

    return finalCocktailList;
  }

  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
    _loadRecommendations();
  }

  Future<void> _showCreateListDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Creating New List'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please fill in data for list.'),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a List Name',
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a description for list',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Create List'),
              onPressed: () {
                //Call Create List
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showListDialog() async {
    var isChecked = false;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to List'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Select a list to Add To..'),
                CheckboxListTile(
                  title: Text("List #1"),
                  subtitle: Text("Description Here..."),
                  checkColor: Colors.white,
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("List #2"),
                  subtitle: Text("Description Here..."),
                  checkColor: Colors.white,
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("List #3"),
                  subtitle: Text("Description Here..."),
                  checkColor: Colors.white,
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
                Text('Want to add to a new list?'),
                TextButton(
                  child: const Text('Create a list'),
                  onPressed: () {
                    _showCreateListDialog();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _checkIfLiked(Cocktail cocktail) async {
    final isFavorite = await FavoritesService.checkIfLiked(cocktail.cocktailID);

    setState(() {
      isLiked = isFavorite;
    });

    return isLiked;
  }

  Future<bool> addToFavoritesCallback(bool isLiked, Cocktail cocktail) async {
    _checkIfLiked(cocktail);
    // isLiked = _checkIfLiked(cocktail) as bool;
    if (isLiked) {
      FavoritesService.removeFromFavorites(cocktail);
    } else {
      FavoritesService.addToFavorites(cocktail);
    }
    setState(() {
      this.isLiked = !isLiked;
    });
    return !isLiked;
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    final recommendations = <Cocktail>[];
    for (final cocktail in _favoriteCocktails) {
      final results = await getRecommendationsFromCocktail(cocktail);
      recommendations.addAll(results);
    }

    setState(() {
      _recommendations = recommendations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _recommendations.isEmpty
              ? Center(child: Text('No recommendations.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Recommendations Based on your ${_favoriteCocktails.length} favorites!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _favoriteCocktails.length,
                        itemBuilder: (BuildContext context, int index) {
                          final cocktail = _favoriteCocktails[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  child: Text(
                                    'Similar to ${cocktail.strCocktailName}:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CocktailCardPage(
                                            cocktail: cocktail),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              FutureBuilder<List<Cocktail>>(
                                future:
                                    getRecommendationsFromCocktail(cocktail),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Cocktail>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Center(
                                      child: Text('No recommendations found.'),
                                    );
                                  } else {
                                    final recommendedCocktails = snapshot.data!;
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: recommendedCocktails.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final recommendedCocktail =
                                            recommendedCocktails[index];
                                        return Slidable(
                                          // Specify a key if the Slidable is dismissible.
                                          key: const ValueKey(0),

                                          // The end action pane is the one at the right or the bottom side.
                                          endActionPane: ActionPane(
                                            motion: ScrollMotion(),
                                            children: [
                                              SlidableAction(
                                                // An action can be bigger than the others.
                                                flex: 1,
                                                backgroundColor:
                                                    Colors.blueAccent,
                                                foregroundColor: Colors.white,
                                                icon: isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                onPressed: (context) =>
                                                    addToFavoritesCallback(
                                                        isLiked,
                                                        recommendedCocktail),

                                                label: 'Favorite',
                                              ),
                                              SlidableAction(
                                                // An action can be bigger than the others.
                                                flex: 1,
                                                onPressed: (context) =>
                                                    _showListDialog(),
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                //icon: Icons.add_circle,
                                                icon: Icons.add_circle,
                                                label: 'Lists',
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            leading: Image.network(
                                              recommendedCocktail.strImageURL,
                                              width: 50.0,
                                              height: 50.0,
                                            ),
                                            title: Text(recommendedCocktail
                                                .strCocktailName),
                                            subtitle: Text(
                                              recommendedCocktail
                                                      .strDescription ??
                                                  '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CocktailCardPage(
                                                          cocktail:
                                                              recommendedCocktail),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRecommendations,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
