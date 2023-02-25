
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: GNav(
            backgroundColor: Colors.grey.shade900,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.purple.shade200,
            padding: EdgeInsets.all(20),
            gap: 8,
            onTabChange: (index){
              print(index);
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(icon: Icons.search, text: "Search",),
              GButton(icon: Icons.list_alt_rounded, text: "Likes",),
              GButton(icon: Icons.settings, text: "Settings",),
            ],
          ),
        ),
      ),
    );
  }
}