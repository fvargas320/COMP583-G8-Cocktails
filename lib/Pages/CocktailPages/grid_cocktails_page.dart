import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../data_model/cocktail.dart';
import 'cocktail_card_page.dart';

class GridCocktails extends StatefulWidget {
  final List<Cocktail> cocktail_list;
  const GridCocktails({Key? key, required this.cocktail_list})
      : super(key: key);

  @override
  State<GridCocktails> createState() => _GridCocktailsState();
}

class _GridCocktailsState extends State<GridCocktails> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            title: Text(
              "Cocktail View ALL",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            backgroundColor: Colors.grey.shade800,
            elevation: 5,
          ),
        ),
        body: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          padding: EdgeInsets.all(14),
          scrollDirection: Axis.vertical,
          itemCount: widget.cocktail_list.length,
          //itemBuilder: (context, index) => buildCard(),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(5.0),
            child: buildCard(index),
          ),
        ),
      );

  Widget buildCard(int index) => Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20)),
        //height: 200,

        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Material(
                  child: Ink.image(
                    image:
                        NetworkImage(widget.cocktail_list[index].strDrinkThumb),
                    fit: BoxFit.cover,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: CocktailCardPage(
                                    cocktail: widget.cocktail_list[index])));
                      },
                    ),
                  ),
                ),
              ),
            ), //Pic

            Text(
              widget.cocktail_list[index].strDrink,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87),
            ), //Cocktail Name
          ],
        ),
      );
}
