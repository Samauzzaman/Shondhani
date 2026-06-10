import 'package:blood_donation/Pages/AdminHomePage.dart';
import 'package:blood_donation/Pages/userHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'demo.dart';
import 'package:blood_donation/Pages/adminsignUp.dart';

class Adminsignin extends StatefulWidget {
  const Adminsignin({super.key});

  @override
  State<Adminsignin> createState() => _AdminsigninState();
}

class _AdminsigninState extends State<Adminsignin> {
  int? User = 0;
  bool isObscure = true;
  bool onPressSignInButton = false;
  bool onPressSignUpButton = false;
  int? switchLanguageValue = 0;
  bool isLoading = false;
  bool isMatch = false;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> signIncheck() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter Both Email and password')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      onPressSignInButton = true;
      isMatch = false; // Reset on every new click
    });

    try {
      // 1. Authenticate account
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      // 2. Fetch role documentation
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        final String role = userData?['role'] ?? 'user';

        if (role == 'admin') {
          // Safe access confirmed!
          setState(() {
            isMatch = true;
          });
        } else {
          // Not an admin
          await FirebaseAuth.instance.signOut();
          setState(() {
            isMatch = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access Denied: You are not an admin', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2), // Keep it on screen
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1500));
          await FirebaseAuth.instance.signOut();
        }
      } else {
        await FirebaseAuth.instance.signOut();
        setState(() {
          isMatch = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isMatch = false;
      });
      String message = "An error occurred. Please try again";
      if (e.code == 'user-not-found')
        message = 'No user found with this email.';
      if (e.code == 'wrong-password') message = 'Incorrect password.';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(CupertinoIcons.back, color: textColor()),
            ),
            centerTitle: true,
            title: Text('Admin Sign In', style: TextStyle(color: Colors.white)),
            backgroundColor: uiBackgroundColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(.5),
                      blurRadius: 25,
                      spreadRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Image.asset('assets/images/blood droplet.png'),
            //Email
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email:',
                        ),
                      ),
                    ),
                  ),
                ),
                //password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                      child: TextField(
                        controller: passwordController,
                        cursorColor: Colors.red,
                        obscureText: isObscure,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password:',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                            icon: Icon(
                              isObscure
                                  ? CupertinoIcons.eye_slash
                                  : CupertinoIcons.eye_fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                //Button
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 10, 8, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          onPressSignInButton = true;
                        });

                        // Wait for the auth process and the 1.5s delay (if it fails) to finish
                        await signIncheck();

                        // Clean, standard navigation logic
                        if (isMatch) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const Adminhomepage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 800),
                            ),
                                (Route<dynamic> route) => false,
                          );
                        } else {
                          // If the match failed, turn the button from Green back to Red
                          if (mounted) {
                            setState(() {
                              onPressSignInButton = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: onPressSignInButton
                            ? Colors.green
                            : const Color.fromRGBO(180, 0, 0, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // 1. The Left Line
                      const Expanded(
                        child: Divider(
                          color: Colors.grey, // Line color
                          thickness: 1, // Line thickness
                        ),
                      ),

                      // 2. The "OR" Text
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                        ), // Space between text and lines
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // 3. The Right Line
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 3, 8, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. ADDED setState: This forces the screen to redraw immediately so the button turns green.
                        setState(() {
                          onPressSignUpButton = true;
                        });

                        // 2. ADDED await: This tells the code to pause here while the user is on the Demo page.
                        await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const AdminSignUp(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            // Replaced 800.ms with standard Duration to prevent errors if you don't have the flutter_animate package.
                            transitionDuration: const Duration(
                              milliseconds: 800,
                            ),
                          ),
                        );

                        // 3. ADDED second setState: When the user hits the "back" button on the Demo page, this resets the button to Red.
                        setState(() {
                          onPressSignUpButton = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        // 4. FIXED the color logic: If true -> Green. If false -> Red.
                        backgroundColor: onPressSignUpButton
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
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
