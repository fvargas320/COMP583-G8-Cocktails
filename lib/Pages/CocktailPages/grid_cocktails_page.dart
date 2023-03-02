import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:convert';
import 'cocktail_card_page.dart';

class GridCocktails extends StatelessWidget {
  final List<Cocktail> cocktail_list;

  const GridCocktails({Key? key, required this.cocktail_list})
      : super(key: key);

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
        body: Container(
          child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            padding: EdgeInsets.all(14),
            scrollDirection: Axis.vertical,
            itemCount: cocktail_list.length,
            //itemBuilder: (context, index) => buildCard(),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(5.0),
              child: buildCard(index),
            ),
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
                    image: NetworkImage(cocktail_list[index].strDrinkThumb),
                    fit: BoxFit.cover,
                    child: InkWell(
                      onTap: () {
                        //   Navigator.push(
                        //       context,
                        //       PageTransition(
                        //           type: PageTransitionType.fade,
                        //           child: CocktailCardPage(
                        //               cocktail: cocktail_list[index])));
                      },
                    ),
                  ),
                ),
              ),
            ), //Pic

            Text(
              cocktail_list[index].strDrink,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87),
            ), //Cocktail Name
          ],
        ),
      );
}

// import 'package:drinkly_cocktails/data_model/cocktail.dart';
// import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';
//
// class GridCocktails extends StatelessWidget {
//   final List<Cocktail> cocktails;
//
//   const GridCocktails({Key? key, required this.cocktails}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(50),
//         child: AppBar(
//           title: Text("Grid View"),
//           backgroundColor: Colors.grey.shade800,
//           elevation: 5,
//         ),
//       ),
//       body: GridView.builder(
//         gridDelegate:
//         SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//         padding: EdgeInsets.all(14),
//         scrollDirection: Axis.vertical,
//         itemCount: cocktails.length,
//         //itemBuilder: (context, index) => buildCard(),
//         itemBuilder: (context, index) => Padding(
//           padding: const EdgeInsets.all(5.0),
//           child: buildCard(index),
//         ),
//       ),
//     );
//   }
//
//   Widget buildCard(int index) => Container(
//     decoration: BoxDecoration(
//         border: Border.all(color: Colors.blue),
//         color: Colors.blue,
//         borderRadius: BorderRadius.circular(20)),
//     //height: 200,
//
//     child: Column(
//       children: [
//         Expanded(
//           child: AspectRatio(
//             aspectRatio: 4 / 3,
//             child: Material(
//               child: Ink.image(
//                 image: NetworkImage(cocktails[index].strDrinkThumb),
//                 fit: BoxFit.cover,
//                 child: InkWell(
//                   onTap: () {},
//                 ),
//               ),
//             ),
//           ),
//         ), //Pic
//
//         Text(
//           cocktails[index].strDrink,
//           style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: Colors.black87),
//         ), //Cocktail Name
//       ],
//     ),
//   );
// }
