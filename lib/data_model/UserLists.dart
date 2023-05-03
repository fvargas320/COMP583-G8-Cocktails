import 'package:cloud_firestore/cloud_firestore.dart';

class UserLists {
  late final String userID;
  late final String listID;
  late final String listName;
  late final String listDescription;
  // late final String cocktailID;

  UserLists({
    required this.userID,
    required this.listID,
    required this.listName,
    required this.listDescription,
    // required this.cocktailID,
  });

  factory UserLists.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return UserLists(
      userID: data?['user_ID'],
      listID: 'list_ID',
      listName: 'list_Name',
      listDescription: 'list_Description',
      // cocktailID: data?['cocktail_ID'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (userID != null) "user_ID": userID,
      if (listID != null) "list_ID": listID,
      if (userID != null) "list_Name": listName,
      if (listDescription != null) "list_Description": listDescription,
      // if (cocktailID != null) "cocktail_ID": cocktailID,
    };
  }
}
