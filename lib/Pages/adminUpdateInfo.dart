import 'package:blood_donation/Pages/updateStatus.dart';
import 'package:blood_donation/Pages/userHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'updateInfo.dart';
import 'demo.dart';
import 'navigator.dart';

class Adminupdateinfo extends StatefulWidget {
  const Adminupdateinfo({super.key});

  @override
  State<Adminupdateinfo> createState() => _AdminupdateinfoState();
}

class _AdminupdateinfoState extends State<Adminupdateinfo> {
  String location = '';
  DateTime date = DateTime.now();
  List<UserUpdate> userUpdateList = [];
  late TextEditingController controller;

  Future<void> approveAndSyncDonation({
    required String userId,
    required String requestId,
  }) async {
    // 1. Setup your database references
    final DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);

    final DocumentReference requestRef = userRef
        .collection('pending requests')
        .doc(requestId);

    try {
      // 2. Get the date field value from the subcollection document
      DocumentSnapshot requestSnapshot = await requestRef.get();

      if (requestSnapshot.exists) {
        final requestData = requestSnapshot.data() as Map<String, dynamic>;
        Timestamp? donationDate = requestData['date']; // 🌟 Grabbed the value!

        // 3. Create a batch to update both places simultaneously
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // Update the subcollection status
        batch.update(requestRef, {'status': 'approved'});

        // Set the field value on the parent collection document
        batch.update(userRef, {'last donated': donationDate});

        // Commit the changes together
        await batch.commit();
        print("Successfully synced date to parent collection!");
      }
    } catch (e) {
      print("Error syncing data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
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
            title: Text('Admin Update', style: TextStyle(color: Colors.white)),
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
                  .collectionGroup('pending requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
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
                    final doc = myRequests[index];
                    final data = doc.data() as Map<String, dynamic>;

                    String requestId = doc.id;
                    String reqLocation = data['location'] ?? 'Unknown';

                    // 🌟 FIX 1: Computed safely as a local variable strictly unique to this card item
                    final String itemStatus = data['status'] ?? 'N/A';

                    String reqUserId =
                        data['user Id'] ??
                        data['userId'] ??
                        data['user id'] ??
                        '';

                    final Timestamp? timeStamp = data['date'];
                    final DateTime reqDate = timeStamp != null
                        ? timeStamp.toDate()
                        : DateTime.now();

                    // 🌟 FIX 2: Gracefully drop non-pending documents out of the pipeline immediately
                    if (itemStatus != 'pending') {
                      return const SizedBox.shrink();
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(reqUserId)
                          .get(),
                      builder: (context, userSnapshot) {
                        String userName = 'Loading Username...';
                        String userBatch = '...';
                        String userBlood = '...';

                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          final userData =
                              userSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                          userName = userData?['name'] ?? 'Unknown Profile';
                          userBatch = userData?['batch'] ?? 'N/A';
                          userBlood = userData?['blood'] ?? 'N/A';
                        }

                        // 🌟 FIX 3: Clean syntax structure with invalid syntax token variations removed
                        return Expanded(
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                tileColor: Colors.grey.shade100,
                                title: Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '📍 Loc: $reqLocation',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '📅 Date: ${DateFormat('d MMMM, yyyy').format(reqDate)}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '🎓 Batch: $userBatch',
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                    Text(
                                      '🩸 Group: $userBlood',
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // 🟢 APPROVE PILL BUTTON
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF62EFB4,
                                                ),
                                                foregroundColor: Colors.black,
                                                elevation: 0,
                                                shape: const StadiumBorder(),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                              ),
                                              onPressed: () async {
                                                approveAndSyncDonation(
                                                  userId: reqUserId,
                                                  requestId: requestId,
                                                );
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(reqUserId)
                                                    .update({
                                                      'point': FieldValue.increment(
                                                        1,
                                                      ),
                                                    });

                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Approved Successfully! ✅',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                'Approve',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),

                                        const SizedBox(height: 10),
                                        // 🔴 REJECT PILL BUTTON
                                           Expanded(
                                             child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFFF5E5E,
                                                ),
                                                foregroundColor: Colors.black,
                                                elevation: 0,
                                                shape: const StadiumBorder(),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                              ),
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection('pending requests')
                                                    .doc(requestId)
                                                    .delete();

                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Request Rejected ❌',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                'Reject',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                                                                       ),
                                           ),

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
