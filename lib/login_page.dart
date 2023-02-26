
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              const Icon(Icons.local_drink_rounded, size: 200, color: Colors.deepPurple ,),
              const SizedBox(height: 20),

              //Hello
            const Text("Welcome to Drinkly", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Discover Amazing Cocktails"
              , style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 45),

            //Email Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0 ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(14)
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      prefixIconColor: Colors.deepPurple,
                      border: InputBorder.none ,
                      hintText: "Email Address",
                    ) ,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            //Password Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0 ),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(14)
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_rounded),
                      prefixIconColor: Colors.deepPurple,
                      border: InputBorder.none ,
                      hintText: "Password",
                    ) ,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            //Sign in button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration:  BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text("Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Not a member? ", style: TextStyle(fontWeight: FontWeight.bold),),
                Text("Register Now", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)
              ],
            ),

            //Register Button
          ],
          ),
        ),
      ),

    );
  }
}