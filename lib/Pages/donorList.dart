import 'dart:math';
import 'package:blood_donation/Pages/userData.dart';
import 'package:blood_donation/Pages/userHomePage.dart';
import 'package:blood_donation/Pages/userInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'demo.dart';
import 'navigator.dart';
import 'userORadmin.dart';

class DonorList extends StatefulWidget {
  const DonorList({super.key});

  @override
  State<DonorList> createState() => _DonorListState();
}

class _DonorListState extends State<DonorList> {
  final TextEditingController searchController = TextEditingController();
  String? selectedCategory = 'Blood Group';
  List<String> categories = ["All", "Name", "Batch", "Blood Group", "Roll"];
  String searchQuery = '';
  bool showOnlyAvailable = false;

  @override
  void dispose() {
    searchController.dispose();
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
            title: Text('Donor List', style: TextStyle(color: Colors.white)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = searchController.text
                            .toLowerCase()
                            .trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search by....",
                      prefixIcon: const Icon(Icons.search, color: Colors.red),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.red.shade900,
                      ),
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                          searchController.clear();
                          searchQuery = "";
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((
                          String value,
                          ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Available Only 🩸'),
                selected: showOnlyAvailable,
                selectedColor: Colors.red.shade100,
                checkmarkColor: Colors.red.shade900,
                labelStyle: TextStyle(
                  color: showOnlyAvailable ? Colors.red.shade900 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                shape: StadiumBorder(side: BorderSide(color: Colors.red.shade200)),
                onSelected: (bool value) {
                  setState(() {
                    showOnlyAvailable = value;
                  });
                },
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('point', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                var leaderboard = snapshot.data!.docs;

                leaderboard = leaderboard.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  bool passesAvailabilityCheck = true;
                  if (data['last donated'] != null) {
                    Timestamp lastDonatedTimestamp = data['last donated'];
                    DateTime lastDonatedDate = lastDonatedTimestamp.toDate();
                    DateTime nextAvailableDate = lastDonatedDate.add(const Duration(days: 90));
                    DateTime today = DateTime.now();

                    if (today.isBefore(nextAvailableDate)) {
                      passesAvailabilityCheck = false;
                    }
                  } else {
                    passesAvailabilityCheck = true;
                  }

                  if (showOnlyAvailable && !passesAvailabilityCheck) {
                    return false;
                  }

                  if (searchQuery.isEmpty) return true;

                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final batch = (data['batch'] ?? '').toString().toLowerCase();
                  final blood = (data['blood'] ?? '').toString().toLowerCase();
                  final roll = (data['roll'] ?? '').toString().toLowerCase();

                  if (selectedCategory == 'Name') {
                    return name.contains(searchQuery);
                  } else if (selectedCategory == 'Blood Group') {
                    return blood.contains(searchQuery);
                  } else if (selectedCategory == 'Batch') {
                    return batch.contains(searchQuery);
                  } else if (selectedCategory == 'Roll') {
                    return roll.contains(searchQuery);
                  } else {
                    return name.contains(searchQuery) ||
                        batch.contains(searchQuery) ||
                        blood.contains(searchQuery) ||
                        roll.contains(searchQuery);
                  }
                }).toList();

                if (leaderboard.isEmpty) {
                  return const Center(child: Text("No matching donors found."));
                }

                return ListView.builder(
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> specificUser =
                    leaderboard[index].data() as Map<String, dynamic>;

                    String donorName = specificUser['name'] ?? 'Anonymous';
                    String donorBatch = specificUser['batch'] ?? 'N/A';
                    String bloodGroup = specificUser['blood'] ?? 'Unknown';
                    int points = specificUser['point'] ?? 0;

                    // 🌟 STEP 1: Determine eligibility parameters explicitly
                    bool isReady = true;
                    int remainingDays = 0;

                    if (specificUser['last donated'] != null) {
                      Timestamp ts = specificUser['last donated'];
                      DateTime nextDate = ts.toDate().add(const Duration(days: 90));
                      DateTime today = DateTime.now();

                      if (today.isBefore(nextDate)) {
                        isReady = false;
                        remainingDays = nextDate.difference(today).inDays;
                      }
                    }

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade50,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          donorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // 🌟 STEP 2: Use Text.rich to apply conditional colors to separate sections
                        subtitle: Text.rich(
                          TextSpan(
                            text: 'Batch: $donorBatch  •  ',
                            style: const TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(
                                text: isReady ? 'Ready ✅' : '⏳ $remainingDays days left',
                                style: TextStyle(
                                  color: isReady ? Colors.green.shade700 : Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                bloodGroup,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$points pts',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        onTap: (){
                          Nav.fadeTo(context, Userdata(userId: leaderboard[index].id));
                        },
                      ),
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