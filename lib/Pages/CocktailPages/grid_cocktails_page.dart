import 'package:cached_network_image/cached_network_image.dart';
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text("Viewing ${widget.cocktail_list.length} Results:"),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                padding: EdgeInsets.all(14),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),

                itemCount: widget.cocktail_list.length,
                //itemBuilder: (context, index) => buildCard(),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: buildCard(index),
                ),
              ),
              Text("Total Results: ${widget.cocktail_list.length}"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "--End of Results--",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      );

  Widget buildCard(int index) => Container(
        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Material(
                  child:
                      // Ink.image(
                      //   image:
                      //       NetworkImage(widget.cocktail_list[index].strImageURL),
                      //   fit: BoxFit.cover,
                      //   child: InkWell(
                      //     onTap: () {
                      //       Navigator.push(
                      //           context,
                      //           PageTransition(
                      //               type: PageTransitionType.fade,
                      //               child: CocktailCardPage(
                      //                   cocktail: widget.cocktail_list[index])));
                      //     },
                      //   ),
                      // ),

                      GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: CocktailCardPage(
                                  cocktail: widget.cocktail_list[index])));
                    },
                    child: CachedNetworkImage(
                      imageUrl: widget.cocktail_list[index].strImageURL,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CachedNetworkImage(
                          imageUrl:
                              "https://cdn-icons-png.flaticon.com/512/2748/2748558.png"),
                    ),
                  ),
                ),
              ),
            ), //Pic

            FittedBox(
              child: Text(
                widget.cocktail_list[index].strCocktailName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87),
              ),
            ), //Cocktail Name
          ],
        ),
      );
}
