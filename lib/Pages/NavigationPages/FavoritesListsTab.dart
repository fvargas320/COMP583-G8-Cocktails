import 'package:drinkly_cocktails/Pages/FinderPages/RecommendationsPage.dart';
import 'package:drinkly_cocktails/Pages/FinderPages/SearchBarTab.dart';
import 'package:drinkly_cocktails/Pages/NavigationPages/user_favorites.dart';
import 'package:flutter/material.dart';

import 'ListsPage.dart';

class FavoritesListTab extends StatelessWidget {
  const FavoritesListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Favorites & Lists"),
          backgroundColor: Colors.grey.shade900,
        ),
        body: Column(
          children: [
            TabBar(
                labelColor: Colors.black87,
                indicatorColor: Colors.deepPurpleAccent,
                tabs: [
                  Tab(
                    text: "Favorites",
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Tab(
                    text: "Lists",
                    icon: Icon(
                      Icons.list_alt,
                      color: Colors.deepPurple,
                    ),
                    // Image.asset('lib/icons/bottle.png')
                  ),
                ]),
            Expanded(
              child: TabBarView(children: [
                FavoritesPage(),
                ListsPage(),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
