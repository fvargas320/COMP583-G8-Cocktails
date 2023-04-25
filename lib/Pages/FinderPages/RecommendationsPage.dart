import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data_model/cocktail.dart';

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
          'maxRecommendations': 5,
        }
      ]
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(body));
    final responseBody = jsonDecode(response.body);

    final hits = responseBody['results'][0]['hits'];

    List<Map<String, dynamic>> results = [];
    print(hits);
    hits.forEach((hit) {
      results.add({
        'Cocktail_Name': hit['Cocktail_Name'],
        'Cocktail_Image': hit['Image_url'],
        'Cocktail_ID': hit['Cocktail_ID']
      });
    });

    return results;
  }
}

class AlgoliaRecommendationWidget extends StatefulWidget {
  @override
  _AlgoliaRecommendationWidgetState createState() =>
      _AlgoliaRecommendationWidgetState();
}

class _AlgoliaRecommendationWidgetState
    extends State<AlgoliaRecommendationWidget> {
  List<Map<String, dynamic>> _recommendations = [];
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
      final cocktail = Cocktail.fromMap(data as Map<String, dynamic>);
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

    for (var i = 0; i < 5; i++) {
      var newCocktail = Cocktail.fromMap(results[i]);
      cocktailList.add(newCocktail);
    }
    return cocktailList;
  }

  bool isLiked = true;
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
      _fetchFavorites();
    });

    // Show a message pop-up to indicate that the cocktail has been deleted
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$cocktail dismissed')));
  }

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _algoliaRecommend.getRecommendations(
        '530',
      ); //String query, int nbHits, List<String> indexNames

      if (!mounted) return; // add check to ensure widget is still mounted

      setState(() {
        _recommendations.addAll(results);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // add check to ensure widget is still mounted

      setState(() {
        _isLoading = false;
      });

      print('Error retrieving recommendations: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
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
                        'Because you liked name here}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recommendations.length,
                        itemBuilder: (BuildContext context, int index) {
                          final result = _recommendations[index];
                          return ListTile(
                            leading: Image.network(result['Cocktail_Image']),
                            title: Text(result['Cocktail_Name']),
                            onTap: () {},
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
