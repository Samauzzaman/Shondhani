import 'package:blood_donation/Pages/AdminHomePage.dart';
import 'package:blood_donation/Pages/UserHomePage.dart';
import 'package:blood_donation/Pages/adminSignIn.dart';
import 'package:blood_donation/Pages/userORadmin.dart';
import 'package:blood_donation/Pages/userSignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Authentication extends StatelessWidget {
  const Authentication({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Case A: User IS logged in
          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, roleSnapshot) {

                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                  // 👇 FIX: Safely extract data as a Map to prevent crashes 👇
                  final userData = roleSnapshot.data!.data() as Map<String, dynamic>?;

                  // If 'role' field is missing or null, it safely defaults to 'user'
                  final String role = userData?['role'] ?? 'user';

                  if (role == 'admin') {
                    return const Adminhomepage();
                  } else {
                    return const Userhomepage();
                  }
                }

                // Fallback: If logged into Auth but Firestore profile document doesn't exist
                return const Useroradmin();
              },
            );
          }

          // Case B: User is NOT logged in
          else {
            return const Useroradmin();
          }
        },
      ),
    );
  }
}