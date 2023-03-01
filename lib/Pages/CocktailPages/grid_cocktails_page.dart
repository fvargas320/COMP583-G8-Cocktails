import 'package:flutter/material.dart';

class GridCocktails extends StatefulWidget {
  const GridCocktails({Key? key}) : super(key: key);

  @override
  State<GridCocktails> createState() => _GridCocktailsState();
}

class _GridCocktailsState extends State<GridCocktails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          title: Text("Grid View"),
          backgroundColor: Colors.grey.shade800,
          elevation: 5,
        ),
      ),
      body: Text("GRID VIEW"),
    );
  }
}
