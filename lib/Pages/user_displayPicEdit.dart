import 'package:drinkly_cocktails/Pages/NavigationPages/user_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'NavigationPages/user_favorites.dart';
class displayPicEditPage extends StatefulWidget {
  @override
  _ProfileScreenState2 createState() => _ProfileScreenState2();
}

class _ProfileScreenState2 extends State<displayPicEditPage> {


  String _displayName = '';
  File? _image;
  final picker = ImagePicker();

  Future <void> initSettings() async{
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    final userProfile = await userRef.get();
    if (!userProfile.exists) {
      await userRef.set({
        'photoURL': null, // set to null or default URL initially
        'displayName': 'New User', // set to default name initially
      }, SetOptions(merge: true)); // Use merge option to only add new fields if they don't exist
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
    await _uploadImage();
  }

  Future<void> _uploadImage() async {
    initSettings();
    if (_image == null) return;

    final user = FirebaseAuth.instance.currentUser!;
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('users/${user.uid}/profile.jpg');

    final task = ref.putFile(_image!);
    final snapshot = await task.whenComplete(() {});

    final url = await snapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'photoURL': url,
    });
  }

  Future<void> _updateDisplayName() async {
    initSettings();
    final user = FirebaseAuth.instance.currentUser!;
    await user.updateDisplayName(_displayName);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'displayName': _displayName,
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: TextField(
              decoration: InputDecoration(
                hintText: 'Enter your display name',
              ),
              onChanged: (value) {
                setState(() {
                  _displayName = value;
                });
              },
            ),
            trailing: IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateDisplayName,
            ),
          ),
        ],
      ),
    );
  }
}
