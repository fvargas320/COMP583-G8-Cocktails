import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'cocktail.dart';

class GetCocktailData {
  final _db = FirebaseFirestore.instance;
  final List<Cocktail> listCocktails = [];

  Future getCocktailsFirestore() async {
    final snapshots = await _db
        .collection("cocktails")
        .where("Main_Flavor", isEqualTo: "Fruity")
        .get()
        .then(
      (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
          print(docSnapshot.data() as Cocktail);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    final docSnap = await snapshots.get();
    final city2 = docSnap.docs;
    // print(city2);

    //var cocktail_list = city2.map((doc) => doc.data()).toList();

    // print("LIST");
    // print(cocktail_list.length);
    // if (cocktail_list != null) {
    //   print(cocktail_list);
    // } else {
    //   print("No such document.");
    // }

    return city2;

    // final cocktailData =
    //     snapshot.docs.map((e) => Cocktail.fromSnapshot(snapshot));
    // print(listCocktails.length);

    // print(cocktailData);
  }
}
