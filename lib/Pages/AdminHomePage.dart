import 'package:blood_donation/Pages/adminUpdateInfo.dart';
import 'package:blood_donation/Pages/demo.dart';
import 'package:blood_donation/Pages/donorList.dart';
import 'package:blood_donation/Pages/updateInfo.dart';
import 'package:blood_donation/Pages/userORadmin.dart';
import 'package:blood_donation/Pages/editProfilePage.dart'; // 🌟 Added for profile modification support
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'navigator.dart';

class Adminhomepage extends StatefulWidget {
  const Adminhomepage({super.key});

  @override
  State<Adminhomepage> createState() => _AdminhomepageState();
}

class _AdminhomepageState extends State<Adminhomepage> {
  int? switchLanguageValue = 0;

  // 🌟 Expanded variables to safely pass information to the Edit Profile layout
  String adminName = '';
  String adminEmail = '';
  String adminMobile = '';
  String adminBatch = '';
  String adminRoll = '';
  String adminBlood = '';

  bool isLoading = true;

  // 🌟 Standardized try/catch network fetcher sequence
  Future<void> fetchAdminData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          adminName = userData['name']?.toString() ?? "No name";
          adminEmail = userData['email']?.toString() ?? "No email";
          adminMobile = userData['mobile']?.toString() ?? "";
          adminBatch = userData['batch']?.toString() ?? "";
          adminRoll = userData['roll']?.toString() ?? "";
          adminBlood = userData['blood']?.toString() ?? "";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching admin properties: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
                color: uiBackgroundColor(),
                border: Border.all(width: 0, color: Colors.transparent),
              ),
              accountName: Text(adminName.isEmpty ? "Loading..." : adminName),
              accountEmail: Text(adminEmail.isEmpty ? "Loading..." : adminEmail),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.red[900]),
              title: const Text('Edit profile'), // 🌟 Replaced placeholder settings option
              splashColor: uiBackgroundColor(),
              onTap: () async {
                Navigator.pop(context); // Safely close the drawer overlay

                String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                Map<String, dynamic> currentData = {
                  'name': adminName,
                  'mobile': adminMobile,
                  'batch': adminBatch,
                  'roll': adminRoll,
                  'blood': adminBlood,
                };

                await Nav.fadeTo(
                  context,
                  EditProfilePage(
                    userId: currentUid,
                    currentData: currentData,
                  ),
                );

                fetchAdminData(); // Refresh metrics instantly on fallback pop routine
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.home, color: Colors.red[900]),
              splashColor: uiBackgroundColor(),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Already home, just drop drawer away cleanly
              },
            ),

            // 🌟 FIXED LOGOUT: Cleaned up duplicate tile layout and added production logic
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              splashColor: uiBackgroundColor(),
              title: const Text('Logout'),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const Useroradmin(),
                      ),
                          (Route<dynamic> route) => false,
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error executing logout sequence: $e")),
                  );
                }
              },
            ),
          ],
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: AppBar(
            leading: IconButton(
              onPressed: () {
                Nav.fadeTo(context, const Useroradmin());
              },
              icon: Icon(CupertinoIcons.back, color: textColor()),
            ),
            centerTitle: true,
            title: const Text('Admin Homepage', style: TextStyle(color: Colors.white)),
            backgroundColor: uiBackgroundColor(),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(.5),
                      blurRadius: 25,
                      spreadRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: iconColor()),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  await Nav.fadeTo(context, const DonorList());
                },
                splashColor: const Color.fromRGBO(180, 0, 0, 0.3),
                child: const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8.0, 15, 8, 8),
                      child: Icon(
                        Icons.bloodtype,
                        color: Color.fromRGBO(180, 0, 0, 1),
                        size: 80,
                      ),
                    ),
                    Text('Donor List'),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  await Nav.fadeTo(context, const Adminupdateinfo());
                },
                splashColor: const Color.fromRGBO(180, 0, 0, 0.3),
                child: const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8.0, 15, 8, 8),
                      child: Icon(
                        Icons.update,
                        color: Color.fromRGBO(180, 0, 0, 1),
                        size: 80,
                      ),
                    ),
                    Text('List Update'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}