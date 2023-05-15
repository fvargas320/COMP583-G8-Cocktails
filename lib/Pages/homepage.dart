import 'package:drinkly_cocktails/Pages/NavigationPages/FavoritesListsTab.dart';
import 'package:drinkly_cocktails/Pages/NavigationPages/user_homepage.dart';
import 'package:drinkly_cocktails/Pages/NavigationPages/user_recommend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:page_transition/page_transition.dart';

import 'NavigationPages/user_favorites.dart';
import 'NavigationPages/user_settings.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    UserHomepage(),
    FinderPage(),
    FavoritesListTab(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   elevation: 10,
      //   backgroundColor: Colors.grey.shade900,
      //   title: const Text(
      //     'Drinkly',
      //     style: TextStyle(fontSize: 14),
      //   ),
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: GNav(
            backgroundColor: Colors.grey.shade900,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.all(20),
            gap: 8,
            onTabChange: (index) {
              print(index);

              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.search,
                text: "Finder",
              ),
              GButton(
                icon: Icons.list_alt_rounded,
                text: "Favorites",
              ),
              GButton(
                icon: Icons.settings,
                text: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
