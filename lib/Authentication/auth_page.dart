


import 'package:drinkly_cocktails/Pages/login_page.dart';
import 'package:drinkly_cocktails/Pages/register_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage ({Key?  key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();

}

class _AuthPageState extends State<AuthPage> {
  // show login page initial
  bool showLoginPage = true;

  void toggleBetweenScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(showRegisterPage: toggleBetweenScreens);
    }

    else {
      return RegisterPage(showLoginPage: toggleBetweenScreens);
    }
  }
}