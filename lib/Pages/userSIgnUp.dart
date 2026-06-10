import 'package:blood_donation/Pages/navigator.dart';
import 'package:blood_donation/Pages/userHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'adminSignIn.dart';
import 'demo.dart';
import 'adminsignUp.dart';
import 'userSignIn.dart';

class Usersignup extends StatefulWidget {
  const Usersignup({super.key});

  @override
  State<Usersignup> createState() => _UsersignupState();
}

class _UsersignupState extends State<Usersignup> {
  int? switchLanguageValue = 0;
  bool onPressSaveButton = false;
  int? User = 0;
  bool isObscure = true;
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController rollController = TextEditingController();
  TextEditingController batchController = TextEditingController();
  TextEditingController bloodController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    rollController.dispose();
    batchController.dispose();
    bloodController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Future<void> signUpCheck() async {
    final name = nameController.text.trim();
    final roll = rollController.text.trim();
    final batch = batchController.text.trim();
    final blood = bloodController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    if (name.isEmpty ||
        roll.isEmpty ||
        batch.isEmpty ||
        blood.isEmpty ||
        mobile.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please, Fill up all the fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password do not match with confirm password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
      onPressSaveButton = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'roll': roll,
        'batch': batch,
        'blood': blood,
        'mobile': mobile,
        'email': email,
        'password': password,
        'role': 'user',
        'point': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'last donated': null
      });
      if (!mounted) return;
      Nav.fadeTo(context, Userhomepage());
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred during sign up.";
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak (minimum 6 characters).';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address format is invalid.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('System Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          onPressSaveButton = false;
        });
      }
    }
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
            title: Text('User Sign Up', style: TextStyle(color: Colors.white)),
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
            Column(
              children: [
                //Name
                Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 15, 8, 8),
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
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name:',
                        ),
                      ),
                    ),
                  ),
                ),

                //Roll
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
                        controller: rollController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Roll:',
                        ),
                      ),
                    ),
                  ),
                ),

                //Batch
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
                        controller: batchController,
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Batch:',
                        ),
                      ),
                    ),
                  ),
                ),

                  //blood group

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
                        controller: bloodController,
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Blood group:',
                        ),
                      ),
                    ),
                  ),
                ),

                //phone number

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
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Mobile:',
                        ),
                      ),
                    ),
                  ),
                ),

                //Email
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

                //ConfirmPassword
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
                        controller: confirmPassController,
                        cursorColor: Colors.red,
                        obscureText: isObscure,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Confirm Password:',
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
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. ADDED setState: This forces the screen to redraw immediately so the button turns green.
                        setState(() {
                          onPressSaveButton = true;
                        });

                        // 2. ADDED await: This tells the code to pause here while the user is on the Demo page.
                        await signUpCheck();

                        // 3. ADDED second setState: When the user hits the "back" button on the Demo page, this resets the button to Red.
                        setState(() {
                          onPressSaveButton = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        // 4. FIXED the color logic: If true -> Green. If false -> Red.
                        backgroundColor: onPressSaveButton
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
                        'Save',
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
