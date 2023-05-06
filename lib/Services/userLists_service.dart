import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drinkly_cocktails/data_model/UserLists.dart';
import 'package:drinkly_cocktails/data_model/cocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListsService {
  static Future<void> createList(
      String listName, String listDesc, BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Check if the list already exists
    final listDoc = await FirebaseFirestore.instance
        .collection('User Lists')
        .doc(userId)
        .collection('Lists')
        .doc(listName)
        .get();

    if (listDoc.exists) {
      // If the list already exists, show a message to the user and prompt them to try again
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('List already exists'),
          content: Text(
              'A list with the same name already exists. Please try a different name.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // If the list doesn't already exist, create a new list with the given name and description
    await FirebaseFirestore.instance
        .collection('User Lists')
        .doc(userId)
        .collection('Lists')
        .doc(listName)
        .set({
      'listName': listName,
      'listDesc': listDesc,
      'cocktailIDs': [],
    });
  }

  static Future<void> addCocktailToList(
      String listName, Cocktail cocktail, BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final listRef = FirebaseFirestore.instance
        .collection("User Lists")
        .doc(userId)
        .collection("Lists")
        .doc(listName);

    // Use a transaction to update the document with the new cocktail_ID
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(listRef);

      if (!snapshot.exists) {
        throw Exception("List does not exist!");
      }

      final cocktailIDs = snapshot.get("cocktailIDs").cast<String>();

      if (cocktailIDs.contains(cocktail.cocktailID)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Cocktail already added'),
              content: Text(
                  'The selected cocktail is already added to the ${listName}.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Cocktail added to list'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }

      cocktailIDs.add(cocktail.cocktailID);

      await transaction.update(listRef, {"cocktailIDs": cocktailIDs});
    });
  }

  static Future<void> removeCocktailFromList(
      String listName, Cocktail cocktail) async {
    await FirebaseFirestore.instance
        .collection('User Lists')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('Lists')
        .doc(listName)
        .update({
      'cocktailIDs': FieldValue.arrayRemove([cocktail.cocktailID])
    });
  }

  static Future<void> deleteEntireList(String listName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance
        .collection("User Lists")
        .doc(userId)
        .collection("Lists")
        .doc(listName)
        .delete();
  }

  static Future<Map<String, dynamic>> getAllLists() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('User Lists')
            .doc(userId)
            .collection('Lists')
            .get();

    final Map<String, dynamic> lists = {};
    for (final doc in querySnapshot.docs) {
      lists[doc.id] = doc.data();
    }

    return lists;
  }

  static Future<List<String>> getAllListNames() async {
    final Map<String, dynamic> listsData = await getAllLists();

    final List<String> listNames = [];
    listsData.forEach((key, value) {
      final String listName = value['listName'];
      listNames.add(listName);
    });

    return listNames;
  }

  static Future<List<String>> getIDsInList(String listName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection("User Lists")
            .doc(userId)
            .collection("Lists")
            .doc(listName)
            .get();

    final List<dynamic> cocktailIDs = snapshot.data()?['cocktailIDs'] ?? [];
    final List<String> cocktailIDStrings = cocktailIDs.cast<String>().toList();

    return cocktailIDStrings;
  }

  static Future<List<dynamic>?> getCocktailIDsInList(String listName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('User Lists')
            .doc(userId)
            .collection('Lists')
            .doc(listName)
            .get();

    if (!documentSnapshot.exists) {
      return null;
    }

    final data = documentSnapshot.data();
    final cocktailIDs = data!['cocktailIDs'];

    return cocktailIDs;
  }
}
