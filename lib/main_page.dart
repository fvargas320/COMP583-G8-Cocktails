

import 'package:drinkly_cocktails/homepage.dart';
import 'package:drinkly_cocktails/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class MainPage extends StatelessWidget {
  const MainPage ({Key?  key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return const MyHomePage();
          }

          else{
            return const LoginPage();
          }
        },
      ),
    );
  }

}