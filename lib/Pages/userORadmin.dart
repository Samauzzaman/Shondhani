import 'package:blood_donation/Pages/AdminHomePage.dart';
import 'package:blood_donation/Pages/UserHomePage.dart';
import 'package:blood_donation/Pages/adminSignIn.dart';
import 'package:blood_donation/Pages/authentication.dart';
import 'package:blood_donation/Pages/commonAdminSignIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'demo.dart';
import 'userSignIn.dart';
import 'navigator.dart';

class Useroradmin extends StatefulWidget {
  static bool isUser = true;
  const Useroradmin({super.key});

  @override
  State<Useroradmin> createState() => _UseroradminState();
}

class _UseroradminState extends State<Useroradmin> {
  bool onPressButtonBackground = false;
  bool onPressAdminButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Image.asset(
          'assets/images/logo.png', // 👈 Put your actual asset path here
        ),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    var currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      await Nav.fadeTo(context, Userhomepage());
                    } else {
                      Nav.fadeTo(context, UserSignIn());
                    }
                    // 1. ADDED setState: This forces the screen to redraw immediately so the button turns green.
                    setState(() {
                      onPressButtonBackground = true;
                      //Useroradmin.isUser = true;
                      //Authentication();
                    });

                    // 2. ADDED await: This tells the code to pause here while the user is on the Demo page.
                    //await Nav.fadeTo(context, UserSignIn());

                    // 3. ADDED second setState: When the user hits the "back" button on the Demo page, this resets the button to Red.
                    setState(() {
                      onPressButtonBackground = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    // 4. FIXED the color logic: If true -> Green. If false -> Red.
                    backgroundColor: onPressButtonBackground
                        ? Colors.green
                        : const Color.fromRGBO(180, 0, 0, 1),
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // Matches your TextFields
                    ),
                    elevation:
                        5, // Adds a shadow that matches your input fields
                  ),
                  child: const Text(
                    'User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                child: ElevatedButton(
                  onPressed: () async {
                    var currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      var userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .get();
                      String role = userDoc.data()?['role'] ?? 'user';
                      if (role == 'admin') {
                        Nav.fadeTo(context, Adminhomepage());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Access denied: Admins Only!!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      Nav.fadeTo(context, CommonAdminsignin());
                    }
                    setState(() {
                      onPressAdminButton = true;
                      // Useroradmin.isUser = false;
                      //Authentication();
                    });

                    //await Nav.fadeTo(context, CommonAdminsignin());

                    // 3. ADDED second setState: When the user hits the "back" button on the Demo page, this resets the button to Red.
                    setState(() {
                      onPressAdminButton = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    // 4. FIXED the color logic: If true -> Green. If false -> Red.
                    backgroundColor: onPressAdminButton
                        ? Colors.green
                        : const Color.fromRGBO(180, 0, 0, 1),
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // Matches your TextFields
                    ),
                    elevation:
                        5, // Adds a shadow that matches your input fields
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
