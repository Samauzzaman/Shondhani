import 'package:blood_donation/Pages/editProfilePage.dart';
import 'package:blood_donation/Pages/userORadmin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'UserHomePage.dart';
import 'demo.dart';
import 'navigator.dart';

class Userdata extends StatefulWidget {
  // 🌟 FIX 1: Correctly declare and pass final parameter through the constructor
  final String? userId;
  const Userdata({super.key, required this.userId});

  @override
  State<Userdata> createState() => _UserdataState();
}

class _UserdataState extends State<Userdata> {
  String userName = '';
  String userEmail = '';
  String userBatch = '';
  String userRoll = '';
  String userBlood = '';
  DateTime? userCreatedAt;
  String userPoint = '';
  String userMobile = '';
  DateTime? userLastDonated;
  String userRole = '';

  // 🌟 FIX 2: Manage an loading state while Firestore completes its asynchronous task
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 🌟 FIX 3: Actually trigger the data fetch immediately on screen load
    fetchUserData();
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat('dd MMM, yyyy').format(dateTime);
  }

  Future<void> fetchUserData() async {
    if (widget.userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      // 🌟 FIX 4: Use 'widget.userId' to read the parameter from the parent widget
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

        // 🌟 FIX 5: Wrap the updates inside setState() to force UI refresh
        setState(() {
          userName = userData['name']?.toString() ?? "No name";
          userEmail = userData['email']?.toString() ?? "No email";
          userBatch = userData['batch']?.toString() ?? "No batch";
          userRoll = userData['roll']?.toString() ?? "No roll";
          userBlood = userData['blood']?.toString() ?? "No blood";
          userCreatedAt = userData['createdAt'] != null
              ? (userData['createdAt'] as Timestamp).toDate()
              : null;

          userLastDonated = userData['last donated'] != null
              ? (userData['last donated'] as Timestamp).toDate()
              : null;
          userPoint = userData['point']?.toString() ?? "No point";
          userMobile = userData['mobile']?.toString() ?? "No mobile";

          userRole = userData['role']?.toString() ?? "User";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => isLoading = false);
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
            title: Text('User Profile', style: TextStyle(color: Colors.white)),
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

      // 🌟 FIX 6: Cleanly switch viewports depending on background state machine status
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Name: $userName',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Batch: $userBatch'),
                          const SizedBox(height: 8),
                          Text('Roll: $userRoll'),
                          const SizedBox(height: 8),
                          Text('Role: $userRole'),
                          const SizedBox(height: 8),
                          Text('Email: $userEmail'),
                          const SizedBox(height: 8),
                          Text(
                            'Account Created: ${formatDateTime(userCreatedAt)}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last Donated: ${formatDateTime(userLastDonated)}',
                          ),
                          const SizedBox(height: 8),
                          Text('Mobile: $userMobile'),
                          const SizedBox(height: 8),
                          Text('Blood Group: $userBlood'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // History Section Header Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: Colors.red[900]),
                        const SizedBox(width: 8),
                        Text(
                          'Donation History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🌟 STREAMBUILDER: Targets the user's specific subcollection live
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .collection('pending requests') // Exact subcollection name
                        .orderBy('date', descending: true) // Sorts by field 'date' inside documents
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: Colors.red),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading history: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Card(
                          elevation: 1,
                          color: Colors.grey.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                "🩸 No previous donation records found.",
                                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        );
                      }

                      final historyDocs = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true, // Prevents view scroll boundary layout crashes
                        physics: const NeverScrollableScrollPhysics(), // Passes control to parent scroller
                        itemCount: historyDocs.length,
                        itemBuilder: (context, index) {
                          final log = historyDocs[index].data() as Map<String, dynamic>;

                          // Safely convert Firestore values
                          DateTime? logDate = log['date'] != null
                              ? (log['date'] as Timestamp).toDate()
                              : null;
                          String logLocation = log['location']?.toString() ?? "Unknown Hospital";
                          String logStatus = log['status']?.toString() ?? "Completed";

                          return Card(
                            elevation: 1.5,
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.shade50,
                                child: Icon(Icons.bloodtype, color: Colors.red.shade800, size: 20),
                              ),
                              title: Text(
                                formatDateTime(logDate),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Location: $logLocation'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: logStatus.toLowerCase() == 'pending'
                                      ? Colors.amber.shade100
                                      : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  logStatus,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: logStatus.toLowerCase() == 'pending'
                                        ? Colors.amber.shade900
                                        : Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ),
                          ).animate().slideY(begin: 0.1, duration: 150.ms * (index + 1).clamp(1, 3));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
