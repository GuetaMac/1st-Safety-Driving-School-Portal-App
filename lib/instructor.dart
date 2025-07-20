import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ---------------- Instructor Dashboard Page ----------------
class InstructorDashboardPage extends StatelessWidget {
  final String instructorName;

  const InstructorDashboardPage({
    super.key,
    this.instructorName = 'Instructor1',
  });

  void handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Dashboard',
      selectedIndex: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Welcome $instructorName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => handleSignOut(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Easily track your driving progress, schedules, and performance through your instructor dashboard.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const MissionCard(),
            const SizedBox(height: 20),
            const DashboardCards(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Mission Card ----------------
class MissionCard extends StatelessWidget {
  const MissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade700,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.yellowAccent),
                const SizedBox(width: 8),
                const Text(
                  'Our Mission',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Our mission is to educate every Filipino Motor Vehicle Driver on Road Safety and instill safe driving practices. We envision a safer road for every Filipino family, with zero fatalities brought about by road crash incidents. ',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'First Safety\nAlways Safe',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Dashboard Info Cards ----------------
class DashboardCards extends StatelessWidget {
  const DashboardCards({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No announcements available.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final announcements = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📢 Announcements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final data =
                    announcements[index].data() as Map<String, dynamic>;
                final title = data['title'] ?? 'No Title';
                final content = data['content'] ?? 'No Content';
                final timestamp = data['date'] as Timestamp?;
                final date = timestamp != null
                    ? '${timestamp.toDate().month}/${timestamp.toDate().day}/${timestamp.toDate().year}'
                    : 'Unknown';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.announcement,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Divider(thickness: 1),
                        const SizedBox(height: 4),
                        Text(
                          content,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// --------------------- Main Scaffold with Drawer ---------------------
class MainScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final int selectedIndex;

  const MainScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.selectedIndex,
  });

  void navigateTo(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = InstructorDashboardPage();
        break;
      case 1:
        targetPage = RecordsPage();
        break;
      case 2:
        targetPage = FeedbacksPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'First Safety Driving School',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red.shade700,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => navigateTo(context, index),
        selectedItemColor: Colors.red.shade700,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Records'),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedbacks',
          ),
        ],
      ),
    );
  }
}

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  String? selectedStatus;

  Future<String?> _getInstructorName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return data['fullName'];
  }

  String _getValidStatus(String? status) {
    const validStatuses = ["Pending", "On Going", "Passed/Completed", "Failed"];
    if (status != null && validStatuses.contains(status)) {
      return status;
    }
    return "Pending";
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "Student Records",
      selectedIndex: 1, // ✅ Ensure Records tab is active
      child: FutureBuilder<String?>(
        future: _getInstructorName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Instructor name not found.'));
          }

          final instructorName = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('enrollments')
                  .where('instructor', isEqualTo: instructorName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (selectedStatus == null) return true;
                  return data['status'] == selectedStatus;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔍 Filter Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text(
                            "Filter by Status:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          DropdownButton<String>(
                            value: selectedStatus,
                            hint: const Text("All"),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: "Pending",
                                child: Text("Pending"),
                              ),
                              DropdownMenuItem(
                                value: "On Going",
                                child: Text("On Going"),
                              ),
                              DropdownMenuItem(
                                value: "Passed/Completed",
                                child: Text("Passed/Completed"),
                              ),
                              DropdownMenuItem(
                                value: "Failed",
                                child: Text("Failed"),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                selectedStatus = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Assigned Students (${students.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: students.isEmpty
                          ? const Center(
                              child: Text(
                                "No students found.",
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final doc = students[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final currentStatus = _getValidStatus(
                                  data['status'],
                                );

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                data['name'] ?? 'No Name',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Phone: ${data['phone'] ?? 'N/A'}",
                                        ), // ✅ Show phone instead of email
                                        Text(
                                          "Course: ${data['course'] ?? 'N/A'}",
                                        ),
                                        Text(
                                          "Schedule: ${data['scheduleDate'] ?? ''} | ${data['startTime'] ?? ''} - ${data['endTime'] ?? ''}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        DropdownButtonFormField<String>(
                                          value: currentStatus,
                                          decoration: InputDecoration(
                                            labelText: 'Status',
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: "Pending",
                                              child: Text("Pending"),
                                            ),
                                            DropdownMenuItem(
                                              value: "On Going",
                                              child: Text("On Going"),
                                            ),
                                            DropdownMenuItem(
                                              value: "Passed/Completed",
                                              child: Text("Passed/Completed"),
                                            ),
                                            DropdownMenuItem(
                                              value: "Failed",
                                              child: Text("Failed"),
                                            ),
                                          ],
                                          onChanged: (newStatus) async {
                                            if (newStatus != null) {
                                              // 🔔 Confirmation Dialog
                                              bool confirm = await showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Confirm Status Update',
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to update the student\'s status?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                    ),
                                                    ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .red
                                                                    .shade700,
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                      child: const Text(
                                                        'Yes, Update',
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                // ✅ Proceed to Update
                                                await FirebaseFirestore.instance
                                                    .collection('enrollments')
                                                    .doc(doc.id)
                                                    .update({
                                                      'status': newStatus,
                                                    });

                                                // 🎉 Success Dialog
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text(
                                                      'Success',
                                                    ),
                                                    content: const Text(
                                                      'Student status updated successfully.',
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .red
                                                                      .shade700,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                        child: const Text('OK'),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class FeedbacksPage extends StatelessWidget {
  const FeedbacksPage({super.key});

  Future<String?> _getInstructorName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.exists ? doc['fullName'] : null;
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "Feedbacks",
      selectedIndex: 2,
      child: FutureBuilder<String?>(
        future: _getInstructorName(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final instructorName = snapshot.data;
          if (instructorName == null) {
            return const Center(child: Text("No instructor data found."));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('feedbacks')
                .where('instructor', isEqualTo: instructorName)
                .snapshots(),
            builder: (context, feedbackSnapshot) {
              if (!feedbackSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final feedbacks = feedbackSnapshot.data!.docs;

              if (feedbacks.isEmpty) {
                return const Center(child: Text("No feedbacks found."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: feedbacks.length,
                itemBuilder: (context, index) {
                  final data = feedbacks[index].data() as Map<String, dynamic>;
                  final instructorEval =
                      data['feedback']?['instructorEvaluation'] ?? {};

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "From: ${data['name'] ?? 'Student'}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Course: ${data['course'] ?? ''}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Divider(),
                          const Text(
                            "Instructor Evaluation:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (var entry in instructorEval.entries)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${entry.key}:",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
