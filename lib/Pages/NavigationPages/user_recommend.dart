import 'package:drinkly_cocktails/Pages/FinderPages/FinderFirstTab.dart';
import 'package:drinkly_cocktails/Pages/FinderPages/SearchBarTab.dart';
import 'package:flutter/material.dart';

class FinderPage extends StatelessWidget {
  const FinderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Finder"),
          backgroundColor: Colors.grey.shade900,
        ),
        body: Column(
          children: [
            TabBar(
                labelColor: Colors.black87,
                indicatorColor: Colors.deepPurpleAccent,
                tabs: [
                  Tab(
                    text: "Recommendations",
                    icon: Image.asset(
                      'assets/icons/recommend.png',
                      scale: 4,
                      color: Colors.deepPurple,
                    ),
                    // Image.asset('lib/icons/bottle.png')
                  ),
                  Tab(
                    text: "Search",
                    icon: Icon(
                      Icons.search,
                      color: Colors.deepPurple,
                    ),
                  ),
                ]),
            Expanded(
              child: TabBarView(children: [
                FinderFirstTab(),
                SearchBarTab(),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
