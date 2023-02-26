import 'package:flutter/material.dart';

class UserRecommendPage extends StatefulWidget {
  const UserRecommendPage({Key? key}) : super(key: key);

  @override
  State<UserRecommendPage> createState() => _UserRecommendPageState();
}

class _UserRecommendPageState extends State<UserRecommendPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: Text(
        "User Recommend Page",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      )),
    );
  }
}
