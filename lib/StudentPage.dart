import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int currentPage = 0;

  final pages = const [
    DashboardPage(),
    CoursesPage(),
    EnrollmentPage(),
    FeedbacksPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentPage, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        selectedItemColor: Colors.red[700],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Courses'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Enrollment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'My Feedbacks',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String name = "Student";
  Map<String, dynamic> enrollmentData = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchEnrollmentData();
  }

  void fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        name = userDoc['fullName'] ?? "Student";
      });
    }
  }

  void fetchEnrollmentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('enrollments')
        .where('userId', isEqualTo: user.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        enrollmentData = querySnapshot.docs.first.data();
      });
    }
  }

  void handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEnrollmentStats(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 150,
                child: statCard(
                  'Instructor',
                  data['instructor']?.toString().isNotEmpty == true
                      ? data['instructor']
                      : 'Pending',
                  Icons.person,
                  Colors.indigo,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 150,
                child: statCard(
                  'Course',
                  data['course'] ?? 'Unknown',
                  Icons.book,
                  Colors.teal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 150,
                child: statCard(
                  'Status',
                  data['status'] ?? 'Pending',
                  Icons.info,
                  Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 150,
                child: statCard(
                  'Schedule',
                  (data['scheduleDate'] != null &&
                          data['startTime'] != null &&
                          data['endTime'] != null)
                      ? '${data['scheduleDate']} (${data['startTime']} - ${data['endTime']})'
                      : 'Not Scheduled',
                  Icons.schedule,
                  Colors.red,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildAnnouncementsSection() {
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
          return const Text('No announcements available.');
        }

        final announcements = snapshot.data!.docs;

        return Column(
          children: announcements.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] ?? 'No Title';
            final content = data['content'] ?? 'No Content';
            final timestamp = data['date'] as Timestamp?;
            final date = timestamp != null
                ? '${timestamp.toDate().month}/${timestamp.toDate().day}/${timestamp.toDate().year}'
                : 'Unknown';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Justified content
                  Text(
                    content,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome $name!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: handleSignOut,
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Easily track your driving progress, schedules, and performance.',
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '🚗 Our mission is to educate every Filipino Motor Vehicle Driver on Road Safety and instill safe driving practices.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              buildEnrollmentStats(enrollmentData),
              const SizedBox(height: 20),
              const Text(
                '📢 Announcements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              buildAnnouncementsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String? selectedScheduleId;
  String? selectedScheduleDate;
  String? selectedStartTime;
  String? selectedEndTime;
  int? selectedSlots;

  void _showEnrollDialog(
    BuildContext context,
    String courseTitle,
    String price,
    bool isTDC,
  ) {
    final _formKey = GlobalKey<FormState>();
    String phoneNumber = '';
    String referenceNumber = '';
    const String gcashNumber = '09123456789';
    bool isLoading = false;

    double priceValue =
        double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    double downPayment = isTDC ? 500.00 : (priceValue * 0.5);

    final schedulesStream = FirebaseFirestore.instance
        .collection('schedules')
        .where('isSeminar', isEqualTo: isTDC)
        .snapshots();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text('Enroll in $courseTitle'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Send your downpayment to:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Center(
                          child: Text(
                            gcashNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text('Total Price: ₱${priceValue.toStringAsFixed(2)}'),
                      Text(
                        'Down Payment: ₱${downPayment.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 15),

                      StreamBuilder<QuerySnapshot>(
                        stream: schedulesStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('Loading schedules...');
                          }
                          final schedules = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return (data['slots'] ?? 0) > 0;
                          }).toList();

                          if (schedules.isEmpty) {
                            return const Text('No available schedules');
                          }

                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Schedule',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: schedules.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final date = data['isSeminar']
                                  ? "${_formatDate(data['startDate'])} - ${_formatDate(data['endDate'])}"
                                  : _formatDate(data['startDate']);
                              return DropdownMenuItem<String>(
                                value: doc.id,
                                child: Text("$date (${data['slots']} slots)"),
                              );
                            }).toList(),
                            onChanged: (val) {
                              final selectedDoc = schedules.firstWhere(
                                (d) => d.id == val,
                              );
                              final data =
                                  selectedDoc.data() as Map<String, dynamic>;
                              setState(() {
                                selectedScheduleId = selectedDoc.id;
                                selectedScheduleDate = data['isSeminar']
                                    ? "${_formatDate(data['startDate'])} - ${_formatDate(data['endDate'])}"
                                    : _formatDate(data['startDate']);
                                selectedStartTime = data['startTime'];
                                selectedEndTime = data['endTime'];
                                selectedSlots = data['slots'];
                              });
                            },
                            validator: (val) =>
                                val == null ? 'Please select a schedule' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Your Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => phoneNumber = val,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Enter phone number';
                          if (!RegExp(r'^[0-9]{10,11}$').hasMatch(val)) {
                            return 'Phone number must be 10-11 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'GCash Reference Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => referenceNumber = val,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Enter reference number';
                          if (!RegExp(r'^[0-9]{8,12}$').hasMatch(val)) {
                            return 'Reference number must be 8-12 digits';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (selectedSlots == null || selectedSlots! <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No available slots for this schedule.',
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                final existingEnrollments =
                                    await FirebaseFirestore.instance
                                        .collection('enrollments')
                                        .where('userId', isEqualTo: user.uid)
                                        .where(
                                          'status',
                                          isNotEqualTo: 'Passed/Completed',
                                        )
                                        .get();

                                if (existingEnrollments.docs.isNotEmpty) {
                                  setState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Finish your current course first.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();
                                final fullName = userDoc.exists
                                    ? userDoc['fullName']
                                    : (user.displayName ?? 'Unknown');

                                await FirebaseFirestore.instance
                                    .collection('enrollments')
                                    .add({
                                      'userId': user.uid,
                                      'name': fullName,
                                      'course': courseTitle,
                                      'phone': phoneNumber,
                                      'reference': referenceNumber,
                                      'gcashNumber': gcashNumber,
                                      'scheduleId': selectedScheduleId,
                                      'scheduleDate': selectedScheduleDate,
                                      'startTime': selectedStartTime,
                                      'endTime': selectedEndTime,
                                      'slots': selectedSlots,
                                      'instructor': '',
                                      'status': 'Pending',
                                      'paid': false,
                                      'price': priceValue,
                                      'downPayment': downPayment,
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });

                                await FirebaseFirestore.instance
                                    .collection('schedules')
                                    .doc(selectedScheduleId)
                                    .update({
                                      'slots': FieldValue.increment(-1),
                                    });

                                Navigator.pop(context);
                                _showSuccessDialog(context);
                              }
                            } catch (e) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enroll Now'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ✅ Success Dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Enrollment Successful!',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Your enrollment has been submitted successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.month}/${date.day}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.52,
          children: [
            buildCourseCard(
              context,
              imageUrl: 'assets/tricycle.png',
              title: 'TRICYCLE',
              code: '(CODE A1)',
              description:
                  '8-Hour Practical Driving Course (PDC) for manual tricycles. Learn basic orientation and safe driving.',
              type: 'manual',
              price: '₱2300.00',
              isTDC: false,
            ),
            buildCourseCard(
              context,
              imageUrl: 'assets/motorcycle.png',
              title: 'MOTORCYCLE',
              code: '(CODE A)',
              description:
                  '8-Hour Practical Driving Course (PDC) for motorcycles. Includes actual driving and orientation.',
              type: 'manual, automatic',
              price: '₱2100.00',
              isTDC: false,
            ),
            buildCourseCard(
              context,
              imageUrl: 'assets/van_refresher.jpg',
              title: 'REFRESHER',
              code: '(CODE B1 - VAN)',
              description:
                  '8-Hour PDC Refresher for manual transmission vans. For those who want to refresh their skills.',
              type: 'manual',
              price: '₱4000.00',
              isTDC: false,
            ),
            buildCourseCard(
              context,
              imageUrl: 'assets/beginner.jpg',
              title: 'BEGINNER',
              code: '(CODE B - SEDAN CAR)',
              description:
                  '12-Hour PDC for beginners. Build confidence and learn essential driving skills.',
              type: 'manual, automatic',
              price: '₱6000.00',
              isTDC: false,
            ),
            buildCourseCard(
              context,
              imageUrl: 'assets/sedan_refresher.png',
              title: 'REFRESHER',
              code: '(CODE B - SEDAN CAR)',
              description:
                  '8-Hour PDC Refresher for sedan cars. For those wanting to refresh their skills.',
              type: 'manual, automatic',
              price: '₱4000.00',
              isTDC: false,
            ),
            buildCourseCard(
              context,
              imageUrl: 'assets/tdc.png',
              title: 'THEORETICAL DRIVING COURSE',
              code: '(TDC)',
              description:
                  'Join our 15-Hour Theoretical Driving Course (TDC) Seminar, a 2-day seminar required for those applying for a Student Permit.',
              type: 'ftof',
              price: '₱1000.00',
              isTDC: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCourseCard(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String code,
    required String description,
    required String type,
    required String price,
    required bool isTDC,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(code, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('Type: $type', style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 8),
                  Text(
                    '₱$price',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showEnrollDialog(context, title, price, isTDC),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Enroll Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnrollmentPage extends StatelessWidget {
  const EnrollmentPage({super.key});

  String _formatCurrency(num value) {
    return '₱${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (match) => '${match[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Enrollments'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view enrollments'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('enrollments')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading enrollments'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No enrollments found.'));
                }

                final enrollments = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: enrollments.length,
                  itemBuilder: (context, index) {
                    final doc = enrollments[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final status = (data['status'] ?? 'Pending').toString();

                    final isFullyPaid =
                        data['paid'] == true ||
                        (data['paymentStatus']?.toString().toLowerCase() ==
                            'fully paid');

                    final price = data['price'] ?? 0;
                    final downPayment = data['downPayment'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// ✅ Course Title
                            Text(
                              data['course'] ?? 'Course',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),

                            /// ✅ Instructor
                            Text(
                              'Instructor: ${data['instructor'] ?? 'Pending'}',
                            ),
                            const SizedBox(height: 8),

                            /// ✅ Schedule Info
                            if (data['scheduleDate'] != null)
                              Text('Schedule: ${data['scheduleDate']}'),
                            if (data['startTime'] != null &&
                                data['endTime'] != null)
                              Text(
                                'Time: ${data['startTime']} - ${data['endTime']}',
                              ),
                            const SizedBox(height: 8),

                            /// ✅ Status
                            Row(
                              children: [
                                const Text('Status: '),
                                Text(
                                  status,
                                  style: TextStyle(
                                    color: status == 'Passed/Completed'
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            /// ✅ Payment Status
                            Row(
                              children: [
                                const Text('Payment: '),
                                Text(
                                  isFullyPaid ? 'Fully Paid' : 'Not Fully Paid',
                                  style: TextStyle(
                                    color: isFullyPaid
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            /// ✅ Price and Down Payment
                            Text(
                              'Price: ${_formatCurrency(price)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Down Payment: ${_formatCurrency(downPayment)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            /// ✅ Feedback Button
                            if (status == 'Passed/Completed')
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('feedbacks')
                                    .where('enrollmentId', isEqualTo: doc.id)
                                    .snapshots(),
                                builder: (context, fbSnapshot) {
                                  if (!fbSnapshot.hasData) {
                                    return const SizedBox();
                                  }

                                  final hasFeedback =
                                      fbSnapshot.data!.docs.isNotEmpty;

                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: (!isFullyPaid || hasFeedback)
                                          ? null
                                          : () {
                                              _showFeedbackDialog(
                                                context,
                                                data['instructor'] ?? 'Unknown',
                                                data['course'] ?? 'Course',
                                                doc.id,
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        disabledBackgroundColor: Colors.grey,
                                      ),
                                      child: Text(
                                        hasFeedback
                                            ? 'Feedback Submitted'
                                            : (!isFullyPaid
                                                  ? 'Pay First'
                                                  : 'Give Feedback'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  bool _isFeedbackComplete(Map<String, Map<String, String>> groupedFeedback) {
    for (var section in groupedFeedback.values) {
      for (var answer in section.values) {
        if (answer.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  /// ✅ Feedback Dialog
  void _showFeedbackDialog(
    BuildContext context,
    String instructor,
    String course,
    String enrollmentId,
  ) {
    Map<String, Map<String, String>> groupedFeedback = {
      'trainingCourse': {
        for (var q in [
          'Objectives were clearly defined',
          'Topics were organized',
          'Participation was encouraged',
          'Useful experience and knowledge',
          'Help me promote road safety',
        ])
          q: '',
      },
      'instructorEvaluation': {
        for (var q in [
          'Instructor is knowledgeable',
          'Instructor is well prepared',
          'Explains clearly and answers questions',
          'Neat and properly dressed',
        ])
          q: '',
      },
      'adminStaff': {
        for (var q in [
          'Neat and properly dressed',
          'Polite and approachable',
          'Knowledgeable on our service provided',
        ])
          q: '',
      },
      'classroom': {
        for (var q in [
          'Clean',
          'No unpleasant smell or odor',
          'Sufficient lighting',
          'Ideal room temperature',
          'Classroom is ideal venue for learning',
        ])
          q: '',
      },
      'vehicle': {
        for (var q in [
          'Clean',
          'No unpleasant smell or odor',
          'Adequate air-conditioning (for Sedan)',
        ])
          q: '',
      },
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Feedback for $course'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeedbackSection(
                  title: 'Training Course',
                  questions: groupedFeedback['trainingCourse']!.keys.toList(),
                  groupKey: 'trainingCourse',
                  groupedFeedback: groupedFeedback,
                ),
                const SizedBox(height: 16),
                Text(
                  'Instructor Evaluation (Instructor: $instructor)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                for (var question
                    in groupedFeedback['instructorEvaluation']!.keys) ...[
                  Text(question),
                  DropdownButtonFormField<String>(
                    items: _dropdownItems(),
                    onChanged: (value) {
                      groupedFeedback['instructorEvaluation']![question] =
                          value ?? '';
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 16),
                _buildFeedbackSection(
                  title: 'Admin Staff',
                  questions: groupedFeedback['adminStaff']!.keys.toList(),
                  groupKey: 'adminStaff',
                  groupedFeedback: groupedFeedback,
                ),
                const SizedBox(height: 16),
                _buildFeedbackSection(
                  title: 'Classroom',
                  questions: groupedFeedback['classroom']!.keys.toList(),
                  groupKey: 'classroom',
                  groupedFeedback: groupedFeedback,
                ),
                const SizedBox(height: 16),
                _buildFeedbackSection(
                  title: 'Vehicle',
                  questions: groupedFeedback['vehicle']!.keys.toList(),
                  groupKey: 'vehicle',
                  groupedFeedback: groupedFeedback,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_isFeedbackComplete(groupedFeedback)) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Incomplete Feedback'),
                      content: const Text(
                        'Please complete all feedback fields before submitting.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                final currentUser = FirebaseAuth.instance.currentUser;

                if (currentUser != null) {
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .get();

                  final studentName = userDoc.exists
                      ? userDoc['fullName']
                      : 'Unknown';

                  await FirebaseFirestore.instance.collection('feedbacks').add({
                    'instructor': instructor,
                    'course': course,
                    'userId': currentUser.uid,
                    'enrollmentId': enrollmentId,
                    'name': studentName,
                    'feedback': groupedFeedback,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback submitted successfully'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeedbackSection({
    required String title,
    required List<String> questions,
    required String groupKey,
    required Map<String, Map<String, String>> groupedFeedback,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        for (var question in questions) ...[
          Text(question),
          DropdownButtonFormField<String>(
            items: _dropdownItems(),
            onChanged: (value) {
              groupedFeedback[groupKey]![question] = value ?? '';
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  List<DropdownMenuItem<String>> _dropdownItems() {
    return const [
      DropdownMenuItem(value: 'Strongly Agree', child: Text('Strongly Agree')),
      DropdownMenuItem(value: 'Agree', child: Text('Agree')),
      DropdownMenuItem(value: 'Neutral', child: Text('Neutral')),
      DropdownMenuItem(value: 'Disagree', child: Text('Disagree')),
    ];
  }
}

class FeedbacksPage extends StatelessWidget {
  const FeedbacksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feedbacks'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view feedbacks'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feedbacks')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No feedback submitted yet.'),
                  );
                }

                final feedbackList = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: feedbackList.length,
                  itemBuilder: (context, index) {
                    final data =
                        feedbackList[index].data() as Map<String, dynamic>;

                    final course = data['course'] ?? 'Unknown Course';
                    final instructor = data['instructor'] ?? 'N/A';
                    final createdAt = data['createdAt'] != null
                        ? (data['createdAt'] as Timestamp).toDate()
                        : DateTime.now();

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Instructor: $instructor',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._buildFeedbackSections(data['feedback'] ?? {}),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  List<Widget> _buildFeedbackSections(Map<String, dynamic> feedbackSections) {
    List<Widget> sections = [];
    feedbackSections.forEach((key, value) {
      if (value is Map) {
        sections.add(
          ExpansionTile(
            title: Text(
              key.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: value.entries
                .map<Widget>(
                  (entry) => ListTile(
                    title: Text(entry.key),
                    trailing: Text(entry.value.toString()),
                  ),
                )
                .toList(),
          ),
        );
      }
    });
    return sections;
  }
}
