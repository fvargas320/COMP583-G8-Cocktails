import 'package:drinkly_cocktails/Pages/login_page.dart';
import 'package:drinkly_cocktails/Authentication/main_page.dart';
import 'package:flutter/material.dart';

import 'Pages/homepage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      //theme: ThemeData(primarySwatch: Colors.blueGrey),
    );
  }
}
