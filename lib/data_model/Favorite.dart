import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  late final String cocktailID;
  late final String userID;

  Favorite({
    required this.cocktailID,
    required this.userID,
  });

  factory Favorite.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return Favorite(cocktailID: data?['cocktail_ID'], userID: data?['user_ID']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (cocktailID != null) "cocktail_ID": cocktailID,
      if (userID != null) "user_ID": userID,
    };
  }
}
