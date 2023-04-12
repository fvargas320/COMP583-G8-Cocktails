import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;

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
            accountName: Text('John Doe'),
            accountEmail: Text('johndoe@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/icons/profile_pic.png'),
            ),
          ),
          ListTile(
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: Text('Add New List'),
            onTap: () {
              // TODO: Implement add new list functionality
            },
          ),
          ListTile(
            title: Text('Sign Out'),
            onTap: () {
              logout();
            },
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
