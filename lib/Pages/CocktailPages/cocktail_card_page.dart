import 'package:cached_network_image/cached_network_image.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import '../../Services/favorites_service.dart';

class CocktailCardPage extends StatefulWidget {
  final Cocktail cocktail;

  CocktailCardPage({Key? key, required this.cocktail}) : super(key: key);

  @override
  _CocktailCardPageState createState() => _CocktailCardPageState();
}

class _CocktailCardPageState extends State<CocktailCardPage> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  void _checkIfLiked() async {
    final isFavorite =
        await FavoritesService.checkIfLiked(widget.cocktail.cocktailID);

    setState(() {
      isLiked = isFavorite;
    });
  }

  Future<bool> addToFavoritesCallback(bool isLiked) async {
    if (isLiked) {
      FavoritesService.removeFromFavorites(widget.cocktail);
    } else {
      FavoritesService.addToFavorites(widget.cocktail);
    }
    return !isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          title: Text(
            "${widget.cocktail.strCocktailName} ${widget.cocktail.cocktailID}",
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          backgroundColor: Colors.grey.shade900,
          elevation: 5,
        ),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          const SizedBox(
            height: 10,
          ),
          CachedNetworkImage(
            imageUrl: widget.cocktail.strImageURL,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/2748/2748558.png"),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.cocktail.strCocktailName,
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
                "Description",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  widget.cocktail.strDescription,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const Text(
                "Ingredients",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.cocktail.strIngredients.split(",").join("\n"),
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "Garnish",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.cocktail.strGarnish,
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "Rim",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.cocktail.strRim,
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
                  widget.cocktail.strPreparation.split(" ,").join("\n"),
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
                isLiked: isLiked,
                onTap: addToFavoritesCallback,
              ),
              Text("Add to Favorites"),
            ],
          ),
        ],
      ),
    );
  }
}
