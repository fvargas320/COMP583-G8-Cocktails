import 'package:flutter/material.dart';

class AddToLists extends StatefulWidget {
  @override
  _AddToListsState createState() => _AddToListsState();
}

class _AddToListsState extends State<AddToLists> {
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Add to lists'),
    );
  }

  void _onChanged1(bool? value) {
    setState(() {
      isChecked1 = value!;
    });
  }

  void _onChanged2(bool? value) {
    setState(() {
      isChecked2 = value!;
    });
  }

  void _onChanged3(bool? value) {
    setState(() {
      isChecked3 = value!;
    });
  }

  Future<void> showCreateListDialog(BuildContext context) async {
    // Your code for creating a new list dialog...
  }

  Future<void> showListDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to List'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Select a list to Add To..'),
                CheckboxListTile(
                  title: Text("List #1"),
                  subtitle: Text("Description Here..."),
                  checkColor: Colors.white,
                  value: isChecked1,
                  onChanged: _onChanged1,
                ),
                CheckboxListTile(
                  title: Text("List #2"),
                  subtitle: Text("Description Here..."),
                  checkColor: Colors.white,
                  value: isChecked2,
                  onChanged: _onChanged2,
                ),
                CheckboxListTile(
                  title: Text("List #3"),
                  subtitle: Text("Description Here..."),
                  checkColor: Colors.white,
                  value: isChecked3,
                  onChanged: _onChanged3,
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
                Text('Want to add to a new list?'),
                TextButton(
                  child: const Text('Create a list'),
                  onPressed: () {
                    showCreateListDialog(context);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
