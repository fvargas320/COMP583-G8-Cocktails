import 'package:drinkly_cocktails/Pages/user_displayPicEdit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_favorites.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage() : super();
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  File? _image;final picker = ImagePicker();
  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
    await _uploadImage();
  }

  Future<void> _uploadImage() async {
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

  final User? user = FirebaseAuth.instance.currentUser;
  String emailID = '';
  String accountName = '';

  @override
  Future<String> getemail() async {
    return '${user?.email}';
  }

  @override
  void initState() {
    super.initState();
    getAccountName().then((name) {
      setState(() {
        accountName = name;
      });
    });
  }


  Future<String> getAccountName() async {
    final uid = user?.uid;
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data()?['displayName'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.grey.shade900,
        elevation: 5,
      ),

      body: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(



            accountName: Text(accountName),
            accountEmail: Text('${user?.email}'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/icons/profile_pic.png'),
            ),
          ),

          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Change profile picture'),
          //   onTap: _pickImage,
          //   trailing: CircleAvatar(
          //     backgroundImage: NetworkImage(
          //       FirebaseAuth.instance.currentUser!.photoURL!,
          //     ),
          //     radius: 25,
          //   ),
          // ),
          ListTile(
            title: Text('Add New List'),
            onTap: () {
              // TODO: Implement add new list functionality
            },
          ),

          ListTile(
            title: Text('Favourites'),
            onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage()),
                );
            },
          ),
          ListTile(
            title: Text('Edit Display Name'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => displayPicEditPage()),
              );
            },
          ),
          ListTile(
            title: Text('Sign Out'),
            onTap: () {
              logout();
            },
          ),
          ListTile(
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

// Call this function to log the user out
Future<void> logout() async {
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print('Error logging out: $e');
  }
}
