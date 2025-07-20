import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int _selectedIndex = 0;
  String loggedInName = 'Loading...';

  final List<Widget> _pages = [
    const AdminDashboard(),
    const EnrollmentsPage(),
    const SchedulesPage(),
    const FeedbackPage(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        loggedInName = userDoc['fullName'] ?? 'Unknown User';
      });
    } else {
      setState(() {
        loggedInName = 'Unknown User';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Dashboard', 'Enrollments', 'Schedules', 'Feedback'][_selectedIndex],
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red.shade700,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Enrollments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
        ],
      ),
    );
  }
}

// Dashboard Content
class AdminDashboard extends StatelessWidget {
  final String name;

  const AdminDashboard({super.key, this.name = "Admin"});

  String getToday() {
    final now = DateTime.now();
    return "${_monthName(now.month)} ${now.day}, ${now.year}";
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final String today = getToday();
    void handleSignOut() {
      Navigator.pushReplacementNamed(context, '/');
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header Section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome $name!',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Easily track your driving progress, schedules, and performance through your student dashboard.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        today,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: handleSignOut,
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 16,
                        ),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              //  Our Mission Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield, color: Colors.yellow, size: 40),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Mission',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Our mission is to educate every Filipino Motor Vehicle Driver on Road Safety and instill safe driving practices. We envision a safer road for every Filipino family, with zero fatalities brought about by road crash incidents.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Dynamic Stats Section
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('enrollments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final enrollments = snapshot.data!.docs;

                  // ✅ Compute stats
                  int totalEnrollments = enrollments.length;
                  double totalEarnings = 0;
                  int notAssignedInstructor = 0;
                  int notFullyPaid = 0;

                  for (var doc in enrollments) {
                    final data = doc.data() as Map<String, dynamic>;

                    // ✅ Add to earnings only if fully paid
                    if (data['paid'] == true && data.containsKey('price')) {
                      totalEarnings += (data['price'] as num).toDouble();
                    }

                    // ✅ No Instructor
                    if ((data['instructor'] == null) ||
                        (data['instructor'] == '')) {
                      notAssignedInstructor++;
                    }

                    // ✅ Not Fully Paid
                    if (data['paid'] == false || data['paid'] == null) {
                      notFullyPaid++;
                    }
                  }

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatCard(
                        number: "$totalEnrollments",
                        title: "Total Enrollments",
                        icon: Icons.group,
                        color: Colors.blue,
                      ),
                      StatCard(
                        number: "₱${totalEarnings.toStringAsFixed(2)}",
                        title: "Total Earnings",
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                      StatCard(
                        number: "$notAssignedInstructor",
                        title: "No Instructor Assigned",
                        icon: Icons.person_off,
                        color: Colors.orange,
                      ),
                      StatCard(
                        number: "$notFullyPaid",
                        title: "Not Fully Paid",
                        icon: Icons.money_off,
                        color: Colors.red,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.number,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class EnrollmentsPage extends StatefulWidget {
  const EnrollmentsPage({super.key});

  @override
  State<EnrollmentsPage> createState() => _EnrollmentsPageState();
}

class _EnrollmentsPageState extends State<EnrollmentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All Enrollments";
  String? defaultTheoreticalInstructor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enrollment Management",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Manage student enrollments, instructor assignments, and payment tracking",
            ),
            const SizedBox(height: 16),

            // ✅ Search & Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by student name ...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 18),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: const [
                    DropdownMenuItem(
                      value: "All Enrollments",
                      child: Text("All Enrollments"),
                    ),
                    DropdownMenuItem(
                      value: "Fully Paid",
                      child: Text("Fully Paid"),
                    ),
                    DropdownMenuItem(value: "Pending", child: Text("Pending")),
                    DropdownMenuItem(
                      value: "Passed/Completed",
                      child: Text("Passed/Completed"),
                    ),
                    DropdownMenuItem(
                      value: "On Going",
                      child: Text("On Going"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ Firestore Data
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('enrollments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading data'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  defaultTheoreticalInstructor = null;
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if ((data['course'] ?? '') ==
                            'THEORETICAL DRIVING COURSE' &&
                        (data['instructor'] ?? '').toString().isNotEmpty) {
                      defaultTheoreticalInstructor = data['instructor'];
                      break;
                    }
                  }

                  // Filter enrollments
                  final filteredEnrollments = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final nameMatch = name.contains(
                      _searchController.text.toLowerCase(),
                    );
                    final String status = (data['status'] ?? '')
                        .toString()
                        .toLowerCase();

                    final filterMatch =
                        _selectedFilter == "All Enrollments" ||
                        (_selectedFilter == "Fully Paid" &&
                            (data['paid'] ?? false)) ||
                        (_selectedFilter == "Pending" && status == 'pending') ||
                        (_selectedFilter == "Passed/Completed" &&
                            status == 'passed/completed') ||
                        (_selectedFilter == "On Going" &&
                            (status == 'in progress' || status == 'ongoing'));

                    return nameMatch && filterMatch;
                  }).toList();

                  if (filteredEnrollments.isEmpty) {
                    return const Center(child: Text("No enrollments found"));
                  }

                  return FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _sortBySchedule(filteredEnrollments),
                    builder: (context, sortedSnapshot) {
                      if (!sortedSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final enrollments = sortedSnapshot.data!;
                      return ListView.builder(
                        itemCount: enrollments.length,
                        itemBuilder: (context, index) {
                          final doc = enrollments[index];
                          final data = doc.data() as Map<String, dynamic>;

                          // ✅ Price & Down Payment
                          final double price =
                              (data['price'] is int || data['price'] is double)
                              ? (data['price'] as num).toDouble()
                              : 0.0;
                          final double downPayment =
                              (data['downPayment'] is int ||
                                  data['downPayment'] is double)
                              ? (data['downPayment'] as num).toDouble()
                              : 0.0;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('schedules')
                                .doc(data['scheduleId'] ?? '')
                                .get(),
                            builder: (context, scheduleSnapshot) {
                              String scheduleInfo = 'No schedule selected';
                              if (scheduleSnapshot.hasData &&
                                  scheduleSnapshot.data!.exists) {
                                final sched =
                                    scheduleSnapshot.data!.data()
                                        as Map<String, dynamic>;
                                scheduleInfo =
                                    '${_formatDate(sched['startDate'])} (${sched['startTime']} - ${sched['endTime']})';
                                if (sched['isSeminar'] == true) {
                                  scheduleInfo +=
                                      ' | 2-day Seminar (Ends: ${_formatDate(sched['endDate'])})';
                                }
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        child: Text(
                                          (data['name'] ?? '?')[0]
                                              .toUpperCase(),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['name'] ?? 'Unknown',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              data['course'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Schedule: $scheduleInfo',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Status: ${data['status'] ?? 'No Status'}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(
                                                  data['status'] ?? '',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              data['createdAt'] != null
                                                  ? _formatDate(
                                                      data['createdAt'],
                                                    )
                                                  : 'No Date',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Price: ₱${price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Down Payment: ₱${downPayment.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // ✅ Assign Instructor Dropdown
                                          _buildInstructorDropdown(
                                            data,
                                            doc.id,
                                          ),
                                          const SizedBox(height: 8),

                                          // ✅ Mark Paid Button
                                          ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    "Confirm Payment",
                                                  ),
                                                  content: const Text(
                                                    "Are you sure you want to mark this as Fully Paid?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                              'enrollments',
                                                            )
                                                            .doc(doc.id)
                                                            .update({
                                                              "paid": true,
                                                            });
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("Yes"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  (data['paid'] ?? false)
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            child: Text(
                                              (data['paid'] ?? false)
                                                  ? "Fully Paid"
                                                  : "Mark Paid",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> _sortBySchedule(
    List<QueryDocumentSnapshot> enrollments,
  ) async {
    List<Map<String, dynamic>> enrollmentsWithDates = [];

    for (var doc in enrollments) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime startDate = DateTime(2100); // default future date
      if (data['scheduleId'] != null && data['scheduleId'] != '') {
        final schedDoc = await FirebaseFirestore.instance
            .collection('schedules')
            .doc(data['scheduleId'])
            .get();
        if (schedDoc.exists && schedDoc['startDate'] != null) {
          startDate = (schedDoc['startDate'] as Timestamp).toDate();
        }
      }
      enrollmentsWithDates.add({'doc': doc, 'startDate': startDate});
    }

    enrollmentsWithDates.sort(
      (a, b) =>
          (a['startDate'] as DateTime).compareTo(b['startDate'] as DateTime),
    );

    return enrollmentsWithDates
        .map((e) => e['doc'] as QueryDocumentSnapshot)
        .toList();
  }

  Widget _buildInstructorDropdown(Map<String, dynamic> data, String docId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'instructor')
          .snapshots(),
      builder: (context, instructorSnapshot) {
        if (instructorSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!instructorSnapshot.hasData ||
            instructorSnapshot.data!.docs.isEmpty) {
          return const Text("No instructors available");
        }

        List<String> instructorNames = instructorSnapshot.data!.docs.map((doc) {
          final instructorData = doc.data() as Map<String, dynamic>;
          return (instructorData['fullName'] ?? 'Unnamed').toString();
        }).toList();

        if (data['course'] == 'THEORETICAL DRIVING COURSE' &&
            defaultTheoreticalInstructor != null) {
          instructorNames = [defaultTheoreticalInstructor!];
        }

        String? selectedInstructor = data['instructor'];
        if (selectedInstructor != null &&
            !instructorNames.contains(selectedInstructor)) {
          selectedInstructor = null;
        }

        return DropdownButton<String>(
          value: selectedInstructor,
          hint: const Text("Assign Instructor", style: TextStyle(fontSize: 12)),
          items: instructorNames
              .map(
                (name) =>
                    DropdownMenuItem<String>(value: name, child: Text(name)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _confirmAssignInstructor(docId, value);
            }
          },
        );
      },
    );
  }

  void _confirmAssignInstructor(String docId, String instructor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: const [
            Icon(Icons.assignment_ind, color: Colors.red),
            SizedBox(width: 8),
            Text("Confirm Assignment"),
          ],
        ),
        content: Text(
          "Are you sure you want to assign $instructor as instructor?",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('enrollments')
                  .doc(docId)
                  .update({"instructor": instructor});

              Navigator.pop(context); // Close confirm dialog

              // Show success dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 28),
                      SizedBox(width: 8),
                      Text("Success"),
                    ],
                  ),
                  content: Text(
                    "Instructor successfully assigned to $instructor!",
                    style: const TextStyle(fontSize: 15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "OK",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'passed/completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
      case 'ongoing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isSeminar = false;
  String filterOption = 'All'; // NEW: filter state
  final TextEditingController slotsController = TextEditingController();

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        endTime = picked;
      });
    }
  }

  Future<void> createSchedule() async {
    if (selectedDate == null ||
        startTime == null ||
        endTime == null ||
        slotsController.text.isEmpty) {
      _showMessage("Please fill in all fields.");
      return;
    }

    final course = isSeminar
        ? "Theoretical Driving Course (TDC)"
        : "Driving Session";

    try {
      await FirebaseFirestore.instance.collection('schedules').add({
        'course': course,
        'startDate': Timestamp.fromDate(selectedDate!),
        'endDate': isSeminar
            ? Timestamp.fromDate(selectedDate!.add(const Duration(days: 1)))
            : null,
        'startTime': startTime!.format(context),
        'endTime': endTime!.format(context),
        'slots': int.parse(slotsController.text),
        'isSeminar': isSeminar,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showMessage("Schedule created successfully!");
      setState(() {
        selectedDate = null;
        startTime = null;
        endTime = null;
        isSeminar = false;
        slotsController.clear();
      });
    } catch (e) {
      _showMessage("Error: $e");
    }
  }

  void _showMessage(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Info"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSchedule(String id) async {
    await FirebaseFirestore.instance.collection('schedules').doc(id).delete();
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.month}/${date.day}/${date.year}";
  }

  Widget buildFilterDropdown() {
    return DropdownButton<String>(
      value: filterOption,
      items: const [
        DropdownMenuItem(value: 'All', child: Text('Show All')),
        DropdownMenuItem(value: 'Available', child: Text('Available Slots')),
        DropdownMenuItem(value: 'Full', child: Text('Fully Booked')),
      ],
      onChanged: (value) {
        setState(() {
          filterOption = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Create and manage your training sessions',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add New Schedule",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      onTap: pickDate,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        hintText: selectedDate != null
                            ? "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}"
                            : 'mm/dd/yyyy',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: pickStartTime,
                            decoration: InputDecoration(
                              labelText: 'Start Time',
                              hintText: startTime?.format(context) ?? '',
                              prefixIcon: const Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: pickEndTime,
                            decoration: InputDecoration(
                              labelText: 'End Time',
                              hintText: endTime?.format(context) ?? '',
                              prefixIcon: const Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: slotsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Available Slots',
                        prefixIcon: const Icon(Icons.event_seat),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isSeminar,
                          onChanged: (value) {
                            setState(() {
                              isSeminar = value ?? false;
                            });
                          },
                        ),
                        const Text("2-day Seminar (TDC)"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: createSchedule,
                        child: const Text(
                          "+ Create Schedule",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [const Text("Filter: "), buildFilterDropdown()],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const Text(
              "Upcoming Sessions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('schedules')
                  .orderBy('startDate')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No schedules available");
                }

                final schedules = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final slots = data['slots'] ?? 0;

                  if (filterOption == 'Available') {
                    return slots > 0;
                  } else if (filterOption == 'Full') {
                    return slots == 0;
                  } else {
                    return true;
                  }
                }).toList();

                if (schedules.isEmpty) {
                  return const Text("No schedules match your filter.");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final data =
                        schedules[index].data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['course'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Date: ${_formatDate(data['startDate'])}",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  "Time: ${data['startTime']} - ${data['endTime']}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  "Slots: ${data['slots']}",
                                  style: TextStyle(
                                    color: (data['slots'] ?? 0) > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (data['isSeminar'] == true)
                                  const Text(
                                    "Seminar: Yes",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _deleteSchedule(schedules[index].id),
                          ),
                        ],
                      ),
                    );
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

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedbacks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading feedbacks"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final feedbacks = snapshot.data!.docs;

          if (feedbacks.isEmpty) {
            return const Center(child: Text("No feedbacks yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final data = feedbacks[index].data() as Map<String, dynamic>;
              final feedbackMap = data['feedback'] ?? {};

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    data['name'] ?? 'Unknown Student',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Course: ${data['course'] ?? 'N/A'}"),
                  childrenPadding: const EdgeInsets.all(12),
                  children: [
                    Text(
                      "Instructor: ${data['instructor'] ?? 'Unknown'}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Divider(thickness: 1),
                    _buildSection(
                      "Training Course",
                      feedbackMap['trainingCourse'],
                    ),
                    const SizedBox(height: 6),
                    _buildSection(
                      "Instructor Evaluation",
                      feedbackMap['instructorEvaluation'],
                    ),
                    const SizedBox(height: 6),
                    _buildSection("Admin Staff", feedbackMap['adminStaff']),
                    const SizedBox(height: 6),
                    _buildSection("Classroom", feedbackMap['classroom']),
                    const SizedBox(height: 6),
                    _buildSection("Vehicle", feedbackMap['vehicle']),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, Map<String, dynamic>? sectionData) {
    if (sectionData == null || sectionData.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        for (var entry in sectionData.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "${entry.key}:",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
      ],
    );
  }
}
