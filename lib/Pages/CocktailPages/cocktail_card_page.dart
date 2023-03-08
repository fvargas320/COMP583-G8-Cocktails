import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class CocktailCardPage extends StatelessWidget {
  final Cocktail cocktail;

  const CocktailCardPage({Key? key, required this.cocktail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          title: Text(
            "${cocktail.strDrink} ${cocktail.idDrink}",
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          backgroundColor: Colors.grey.shade800,
          elevation: 5,
        ),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          const SizedBox(
            height: 10,
          ),
          Image.network(
            cocktail.strDrinkThumb,
            height: 400,
            width: 400,
            //fit: BoxFit.fitHeight,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            cocktail.strDrink,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              const Text(
                "Ingredients",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                cocktail.strIngredient1,
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                cocktail.strMeasure1,
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              const Text(
                "Recipe Instructions",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  cocktail.strInstructions,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LikeButton(
                likeCount: 1,
              ),
              const SizedBox(
                width: 30,
              ),
              LikeButton(
                likeBuilder: (isLiked) {
                  return Icon(
                    Icons.add_circle,
                    color: Colors.grey.shade500,
                    size: 30,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
