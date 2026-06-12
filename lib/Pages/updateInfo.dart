import 'package:blood_donation/Pages/updateStatus.dart';
import 'package:blood_donation/Pages/userHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'demo.dart';
import 'navigator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateInfo extends StatefulWidget {
  const UpdateInfo({super.key});

  @override
  State<UpdateInfo> createState() => _UpdateInfoState();
}

class _UpdateInfoState extends State<UpdateInfo> {
  String location = '';
  DateTime date = DateTime.now();
  String? currentUserId;
  List<UserUpdate> userUpdateList = [];
  late TextEditingController locationController;

  // 🌟 FIX 1: Pass data explicitly to the function to avoid race conditions with clearing controllers
  Future<void> submitRequestToAdmin(String targetLocation, DateTime targetDate) async {
    if (targetLocation.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).collection('pending requests').add({
        'user Id': currentUserId,
        'location': targetLocation,
        'date': Timestamp.fromDate(targetDate),
        'status': 'pending',
        'submitted at': FieldValue.serverTimestamp(),
      });


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification pending'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error while submitting: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    locationController = TextEditingController();
    // 🌟 FIX 2: Fetch current logged-in user ID immediately upon creation so stream registers data instantly
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    locationController.dispose();
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
            title: Text('Donation', style: TextStyle(color: Colors.white)),
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users').doc(currentUserId).collection('pending requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.red));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "You have no pending requests",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final myRequests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: myRequests.length,
                  itemBuilder: (context, index) {
                    final data = myRequests[index].data() as Map<String, dynamic>;
                    String reqLocation = data['location'] ?? 'Unknown';

                    // 🌟 FIX 3: Localized variable tracking inside builder loop
                    final String itemStatus = data['status'] ?? 'Unknown';

                    final Timestamp? timeStamp = data['date'];
                    final DateTime reqDate = timeStamp != null
                        ? timeStamp.toDate()
                        : DateTime.now();

                    // 🌟 FIX 4: Use zero-pixel clean filter out instead of printing Text stacks
                    if (itemStatus != 'pending') {
                      return const SizedBox.shrink();
                    }

                    return ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          tileColor: Colors.grey.shade100,
                          title: Text(
                            reqLocation,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(DateFormat('d MMMM, yyyy').format(reqDate)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'pending',
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await openDialogue();

          if (result == null || result.location.isEmpty) return;

          setState(() {
            location = result.location;
            userUpdateList.add(result);
          });

          // 🌟 FIX 5: Fire off the database request safely using static text block captures
          await submitRequestToAdmin(result.location, result.date);

          locationController.clear();
        },
        label: const Text(
          'New Donation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: uiBackgroundColor(),
      ),
    );
  }

  Future<UserUpdate?> openDialogue() => showDialog<UserUpdate>(
    context: context,
    builder: (dialogueContext) => AlertDialog(
      content: TextField(
        onSubmitted: (_) {
          if (locationController.text.isNotEmpty) {
            Navigator.of(dialogueContext).pop(UserUpdate(location: locationController.text, date: date));
          }
        },
        decoration: const InputDecoration(hintText: 'Location'),
        autofocus: true,
        controller: locationController,
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1990),
              lastDate: DateTime(2100),
            );
            if (newDate == null) return;
            setState(() => date = newDate);
          },
          label: const Text('Date'),
        ),
        TextButton(
          onPressed: () {
            if (locationController.text.trim().isNotEmpty) {
              Navigator.of(dialogueContext).pop(
                UserUpdate(location: locationController.text.trim(), date: date),
              );
            } else {
              Navigator.of(dialogueContext).pop();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}