import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendationsTab {
  final String _appId;
  final String _apiKey;
  final String _indexName;

  RecommendationsTab(this._appId, this._apiKey, this._indexName);

  Future<List<Map<String, dynamic>>> getRecommendations(
      String query, int nbHits, String indexName) async {
    final url = 'https://' +
        _appId +
        '-dsn.algolia.net/1/indexes/' +
        //indexName +
        '*/recommendations';
    final headers = {
      'X-Algolia-API-Key': _apiKey,
      'X-Algolia-Application-Id': _appId,
      'Content-Type': 'application/json'
    };
    final body = [
      {
        'indexName': 'Cocktails',
        'query': query,
        'model': 'related-products',
        'threshold': 0,
        'maxRecommendations': nbHits
      }
    ];

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(body));
    print(response.body);
    final responseBody = jsonDecode(response.body);
    print("HERE1");
    print(responseBody['hits']);
    print("HERE2");
    return responseBody['hits'].cast<Map<String, dynamic>>();
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
              : ListView.builder(
                  itemCount: _recommendations.length,
                  itemBuilder: (BuildContext context, int index) {
                    final result = _recommendations[index];
                    return ListTile(
                      title: Text(result['Cocktail_Name']),
                      subtitle: Text("HI"),
                      // trailing: Text('\$${result['price']}'),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!mounted) return; // add check to ensure widget is still mounted

          setState(() {
            _isLoading = true;
          });

          try {
            final results = await _algoliaRecommend.getRecommendations(
              '1662',
              10,
              'Cocktails',
            ); //String query, int nbHits, List<String> indexNames
            print(results);

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
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
