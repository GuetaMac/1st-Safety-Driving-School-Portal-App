import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardContent(),
    const RecordsPage(),
    const AnnouncementsPage(),
    const FeedbacksPage(),
    const ManagerAnalyticsDashboard(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Records',
    'Announcements',
    'Feedbacks',
    'Analytics',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedbacks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

// Dashboard Content
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Mam Ghe!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor your driving school operations and track key metrics',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Today',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    today,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: handleSignOut,
                    icon: const Icon(Icons.logout, color: Colors.red, size: 16),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Mission Section
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
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
              int pendingPayments = 0;
              int totalTDC = 0;
              int totalPDC = 0;

              for (var doc in enrollments) {
                final data = doc.data() as Map<String, dynamic>;
                final courseName = (data['course'] ?? '')
                    .toString()
                    .toUpperCase();

                bool isTDC = courseName.contains('THEORETICAL');

                // ✅ Count per course
                if (isTDC) {
                  totalTDC++;
                } else {
                  totalPDC++;
                }

                // ✅ Pending payments
                if (data['paid'] != true) {
                  pendingPayments++;
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
                    number: "$pendingPayments",
                    title: "Pending Payments",
                    icon: Icons.pending_actions,
                    color: Colors.redAccent,
                  ),
                  StatCard(
                    number: "$totalTDC",
                    title: "Total TDC Enrollments",
                    icon: Icons.menu_book,
                    color: Colors.indigo,
                  ),
                  StatCard(
                    number: "$totalPDC",
                    title: "Total PDC Enrollments",
                    icon: Icons.directions_car,
                    color: Colors.teal,
                  ),
                ],
              );
            },
          ),
        ],
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

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String fullName = '';
  String email = '';
  String password = '';
  String selectedRole = 'admin'; // Default role
  String filterRole = 'All'; // Filter for account list

  final List<String> roles = ['admin', 'instructor'];

  Future<void> createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        // ✅ Create new account in Firebase Auth
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            );

        // ✅ Save user details in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'role': selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedRole.toUpperCase()} account created successfully!',
            ),
          ),
        );

        // ✅ Clear fields
        setState(() {
          fullName = '';
          email = '';
          password = '';
        });
        _formKey.currentState!.reset();
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error creating account')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
              showSuccessDialog('Account deleted successfully.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            customTextField(
                              'Full Name',
                              (val) => fullName = val,
                            ),
                            const SizedBox(height: 12),
                            customTextField(
                              'Email Address',
                              (val) => email = val,
                            ),
                            const SizedBox(height: 12),
                            customTextField(
                              'Password',
                              (val) => password = val,
                              obscure: true,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Select Role',
                                border: OutlineInputBorder(),
                              ),
                              items: roles.map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedRole = val!),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : createAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Accounts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: filterRole,
                    items: ['All', 'admin', 'instructor'].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) => setState(() => filterRole = value!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', whereIn: ['admin', 'instructor'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (filterRole == 'All') return true;
                    return data['role'] == filterRole;
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final data = users[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade700,
                            child: Text(
                              data['role'].substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            data['fullName'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${data['email'] ?? ''}\nRole: ${data['role'] ?? ''}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    showDeleteConfirmation(users[index].id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customTextField(
    String label,
    Function(String) onChanged, {
    bool obscure = false,
  }) {
    bool isPassword = obscure;
    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: obscure
                ? IconButton(
                    icon: Icon(
                      isPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isPassword = !isPassword;
                      });
                    },
                  )
                : null,
          ),
          onChanged: onChanged,
          validator: (val) => val!.isEmpty ? 'Enter $label' : null,
        );
      },
    );
  }
}
// Announcements Page

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// ✅ Create new announcement
  void _createAnnouncement() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Announcement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        _showSuccessDialog('Please fill in all fields.');
                        return;
                      }
                      await FirebaseFirestore.instance
                          .collection('announcements')
                          .add({
                            'title': titleController.text,
                            'content': contentController.text,
                            'date': FieldValue.serverTimestamp(),
                          });
                      Navigator.pop(context);
                      _showSuccessDialog(
                        'You successfully posted an announcement.',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Post Announcement',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ Edit announcement
  void _editAnnouncement(
    String docId,
    String currentTitle,
    String currentContent,
  ) {
    final titleController = TextEditingController(text: currentTitle);
    final contentController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
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
                await FirebaseFirestore.instance
                    .collection('announcements')
                    .doc(docId)
                    .update({
                      'title': titleController.text,
                      'content': contentController.text,
                      'date': FieldValue.serverTimestamp(),
                    });
                Navigator.pop(context);
                _showSuccessDialog('Announcement updated successfully.');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Delete announcement
  void _deleteAnnouncement(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this announcement?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('announcements')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Announcements',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage and broadcast important announcements',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _createAnnouncement,
                icon: const Icon(Icons.add),
                label: const Text('New Announcement'),
              ),
            ),
            const SizedBox(height: 16),

            /// ✅ Real-time announcements
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('announcements')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No announcements yet.'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      final title = data['title'] ?? '';
                      final content = data['content'] ?? '';
                      final timestamp = data['date'] as Timestamp?;
                      final date = timestamp?.toDate() ?? DateTime.now();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(content),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _editAnnouncement(docId, title, content),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteAnnouncement(docId),
                              ),
                            ],
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
      ),
    );
  }
}
// Feedbacks Page

class FeedbacksPage extends StatelessWidget {
  const FeedbacksPage({super.key});

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
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  collapsedBackgroundColor: Colors.grey.shade100,
                  backgroundColor: Colors.white,
                  iconColor: Colors.red,
                  collapsedIconColor: Colors.red,
                  title: Text(
                    data['name'] ?? 'Unknown Student',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "Course: ${data['course'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      "Instructor: ${data['instructor'] ?? 'Unknown'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
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
                Flexible(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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

class ManagerAnalyticsDashboard extends StatefulWidget {
  const ManagerAnalyticsDashboard({super.key});

  @override
  State<ManagerAnalyticsDashboard> createState() =>
      _ManagerAnalyticsDashboardState();
}

class _ManagerAnalyticsDashboardState extends State<ManagerAnalyticsDashboard> {
  String _selectedRange = 'This Month';
  final List<String> _ranges = [
    'Today',
    'This Month',
    'Last 3 Months',
    'All Time',
  ];

  Future<Map<String, dynamic>> fetchAnalytics() async {
    DateTime now = DateTime.now();
    DateTime startDate;

    if (_selectedRange == 'Today') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (_selectedRange == 'This Month') {
      startDate = DateTime(now.year, now.month, 1);
    } else if (_selectedRange == 'Last 3 Months') {
      startDate = DateTime(now.year, now.month - 2, 1);
    } else {
      startDate = DateTime(2000); // All Time
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('enrollments')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .get();

    int totalEnrollments = snapshot.docs.length;
    int pendingPayments = 0;
    int totalTDC = 0;
    int totalPDC = 0;
    int totalRefresher = 0;
    double totalRevenue = 0;

    Map<String, int> monthlyEnrollments = {};
    Map<String, double> monthlyRevenue = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String courseName = (data['course'] ?? '').toString().toUpperCase();
      bool isTDC = courseName.contains('THEORETICAL');
      bool isPDC = courseName.contains('PRACTICAL');
      bool isRefresher = courseName.contains('REFRESHER');

      // Count TDC/PDC/Refresher
      if (isTDC) {
        totalTDC++;
      } else if (isPDC) {
        totalPDC++;
      } else if (isRefresher) {
        totalRefresher++;
      }

      // Pending Payments
      if (data['paid'] != true) {
        pendingPayments++;
      }

      // Total Revenue
      if (data['paid'] == true && data.containsKey('price')) {
        totalRevenue += (data['price'] as num).toDouble();
      }

      // Monthly Stats
      DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
      String month =
          "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}";
      monthlyEnrollments[month] = (monthlyEnrollments[month] ?? 0) + 1;
      if (data['paid'] == true && data.containsKey('price')) {
        monthlyRevenue[month] =
            (monthlyRevenue[month] ?? 0) + (data['price'] as num).toDouble();
      }
    }

    return {
      'totalEnrollments': totalEnrollments,
      'pendingPayments': pendingPayments,
      'totalTDC': totalTDC,
      'totalPDC': totalPDC,
      'totalRefresher': totalRefresher,
      'totalRevenue': totalRevenue,
      'monthlyEnrollments': monthlyEnrollments,
      'monthlyRevenue': monthlyRevenue,
    };
  }

  String _formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(0)}';
  }

  String _formatMonth(String month) {
    final parts = month.split('-');
    final year = parts[0];
    final monthNum = int.parse(parts[1]);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[monthNum - 1]} $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Date Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Filter by: ", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedRange,
                  items: _ranges.map((range) {
                    return DropdownMenuItem<String>(
                      value: range,
                      child: Text(range),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRange = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: fetchAnalytics(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                final totalEnrollments = data['totalEnrollments'];
                final pendingPayments = data['pendingPayments'];
                final totalTDC = data['totalTDC'];
                final totalPDC = data['totalPDC'];
                final totalRefresher = data['totalRefresher'];
                final totalRevenue = data['totalRevenue'];
                final monthlyEnrollments =
                    data['monthlyEnrollments'] as Map<String, int>;
                final monthlyRevenue =
                    data['monthlyRevenue'] as Map<String, double>;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ KPI Cards
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(
                            number: "$totalEnrollments",
                            title: "Total Enrollments",
                            icon: Icons.group,
                            color: Colors.blue,
                          ),
                          StatCard(
                            number: "$pendingPayments",
                            title: "Pending Payments",
                            icon: Icons.pending_actions,
                            color: Colors.redAccent,
                          ),
                          StatCard(
                            number: _formatCurrency(totalRevenue),
                            title: "Total Revenue",
                            icon: Icons.monetization_on,
                            color: Colors.green,
                          ),
                          StatCard(
                            number:
                                "${((totalRevenue / (totalEnrollments > 0 ? totalEnrollments : 1)).toStringAsFixed(0))}",
                            title: "Avg Rev/Student",
                            icon: Icons.trending_up,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ✅ Monthly Enrollment Chart
                      Card(
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
                                "Monthly Enrollments",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                child: monthlyEnrollments.isEmpty
                                    ? Center(
                                        child: Text(
                                          "No enrollment data available",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      )
                                    : Builder(
                                        builder: (context) {
                                          // ✅ Better month sorting - handle different date formats
                                          final sortedEntries =
                                              monthlyEnrollments.entries.toList()..sort((
                                                a,
                                                b,
                                              ) {
                                                try {
                                                  // Try parsing as YYYY-MM format first
                                                  if (a.key.contains('-') &&
                                                      a.key.length >= 7) {
                                                    return a.key.compareTo(
                                                      b.key,
                                                    );
                                                  }

                                                  // Try parsing as month names
                                                  final monthNames = [
                                                    'January',
                                                    'February',
                                                    'March',
                                                    'April',
                                                    'May',
                                                    'June',
                                                    'July',
                                                    'August',
                                                    'September',
                                                    'October',
                                                    'November',
                                                    'December',
                                                  ];

                                                  final aIndex = monthNames
                                                      .indexWhere(
                                                        (month) => a.key
                                                            .toLowerCase()
                                                            .contains(
                                                              month
                                                                  .toLowerCase(),
                                                            ),
                                                      );
                                                  final bIndex = monthNames
                                                      .indexWhere(
                                                        (month) => b.key
                                                            .toLowerCase()
                                                            .contains(
                                                              month
                                                                  .toLowerCase(),
                                                            ),
                                                      );

                                                  if (aIndex != -1 &&
                                                      bIndex != -1) {
                                                    return aIndex.compareTo(
                                                      bIndex,
                                                    );
                                                  }

                                                  // Fallback to string comparison
                                                  return a.key.compareTo(b.key);
                                                } catch (e) {
                                                  return a.key.compareTo(b.key);
                                                }
                                              });

                                          final months = sortedEntries
                                              .map((e) => e.key)
                                              .toList();
                                          final maxValue = sortedEntries.isEmpty
                                              ? 0
                                              : sortedEntries
                                                    .map((e) => e.value)
                                                    .reduce(
                                                      (a, b) => a > b ? a : b,
                                                    );

                                          return LineChart(
                                            LineChartData(
                                              backgroundColor: Colors.grey[50],
                                              minX: 0,
                                              maxX: (months.length - 1)
                                                  .toDouble(),
                                              minY: 0,
                                              maxY: (maxValue * 1.1).toDouble(),
                                              gridData: FlGridData(
                                                show: true,
                                                drawHorizontalLine: true,
                                                drawVerticalLine: true,
                                                getDrawingHorizontalLine:
                                                    (value) => FlLine(
                                                      color: Colors.grey[300],
                                                      strokeWidth: 1,
                                                    ),
                                                getDrawingVerticalLine:
                                                    (value) => FlLine(
                                                      color: Colors.grey[200],
                                                      strokeWidth: 0.5,
                                                    ),
                                              ),
                                              titlesData: FlTitlesData(
                                                show: true,
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 40,
                                                    interval: 1,
                                                    getTitlesWidget: (value, meta) {
                                                      final index = value
                                                          .toInt();
                                                      if (index < 0 ||
                                                          index >=
                                                              months.length) {
                                                        return const SizedBox.shrink();
                                                      }

                                                      // Show every month but rotate text for better visibility
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 8.0,
                                                            ),
                                                        child: Transform.rotate(
                                                          angle: -0.5,
                                                          child: Text(
                                                            _formatMonth(
                                                              months[index],
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 40,
                                                    interval: maxValue > 10
                                                        ? (maxValue / 5)
                                                              .ceilToDouble()
                                                        : 1,
                                                    getTitlesWidget: (value, meta) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              right: 8.0,
                                                            ),
                                                        child: Text(
                                                          value
                                                              .toInt()
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                                topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                              ),
                                              borderData: FlBorderData(
                                                show: true,
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                  width: 1,
                                                ),
                                              ),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: sortedEntries
                                                      .asMap()
                                                      .entries
                                                      .map((entry) {
                                                        final index = entry.key
                                                            .toDouble();
                                                        final count = entry
                                                            .value
                                                            .value
                                                            .toDouble();
                                                        return FlSpot(
                                                          index,
                                                          count,
                                                        );
                                                      })
                                                      .toList(),
                                                  isCurved: true,
                                                  curveSmoothness: 0.3,
                                                  color: Colors.blue,
                                                  barWidth: 3,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter:
                                                        (
                                                          spot,
                                                          percent,
                                                          barData,
                                                          index,
                                                        ) {
                                                          return FlDotCirclePainter(
                                                            radius: 5,
                                                            color: Colors.blue,
                                                            strokeWidth: 2,
                                                            strokeColor:
                                                                Colors.white,
                                                          );
                                                        },
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    color: Colors.blue
                                                        .withOpacity(0.1),
                                                  ),
                                                  shadow: const Shadow(
                                                    color: Colors.blue,
                                                    blurRadius: 3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      // ✅  Monthly Revenue Chart
                      Card(
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
                                "Monthly Revenue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                child: monthlyRevenue.isEmpty
                                    ? Center(
                                        child: Text(
                                          "No revenue data available",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      )
                                    : Builder(
                                        builder: (context) {
                                          // ✅ Sort months properly
                                          final sortedEntries =
                                              monthlyRevenue.entries.toList()
                                                ..sort((a, b) {
                                                  try {
                                                    // Handle YYYY-MM format
                                                    if (a.key.contains('-') &&
                                                        a.key.length >= 7) {
                                                      return a.key.compareTo(
                                                        b.key,
                                                      );
                                                    }

                                                    // Handle month names
                                                    final monthNames = [
                                                      'January',
                                                      'February',
                                                      'March',
                                                      'April',
                                                      'May',
                                                      'June',
                                                      'July',
                                                      'August',
                                                      'September',
                                                      'October',
                                                      'November',
                                                      'December',
                                                    ];

                                                    final aIndex = monthNames
                                                        .indexWhere(
                                                          (month) => a.key
                                                              .toLowerCase()
                                                              .contains(
                                                                month
                                                                    .toLowerCase(),
                                                              ),
                                                        );
                                                    final bIndex = monthNames
                                                        .indexWhere(
                                                          (month) => b.key
                                                              .toLowerCase()
                                                              .contains(
                                                                month
                                                                    .toLowerCase(),
                                                              ),
                                                        );

                                                    if (aIndex != -1 &&
                                                        bIndex != -1) {
                                                      return aIndex.compareTo(
                                                        bIndex,
                                                      );
                                                    }

                                                    return a.key.compareTo(
                                                      b.key,
                                                    );
                                                  } catch (e) {
                                                    return a.key.compareTo(
                                                      b.key,
                                                    );
                                                  }
                                                });

                                          final months = sortedEntries
                                              .map((e) => e.key)
                                              .toList();
                                          final maxValue = sortedEntries.isEmpty
                                              ? 0.0
                                              : sortedEntries
                                                    .map((e) => e.value)
                                                    .reduce(
                                                      (a, b) => a > b ? a : b,
                                                    );

                                          return BarChart(
                                            BarChartData(
                                              backgroundColor: Colors.grey[50],
                                              maxY:
                                                  maxValue *
                                                  1.2, // Add padding to top
                                              gridData: FlGridData(
                                                show: true,
                                                drawHorizontalLine: true,
                                                drawVerticalLine: false,
                                                getDrawingHorizontalLine:
                                                    (value) => FlLine(
                                                      color: Colors.grey[300],
                                                      strokeWidth: 1,
                                                    ),
                                              ),
                                              titlesData: FlTitlesData(
                                                show: true,
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize:
                                                        50, // ✅ Increased space for labels
                                                    interval: 1,
                                                    getTitlesWidget: (value, meta) {
                                                      final index = value
                                                          .toInt();
                                                      if (index < 0 ||
                                                          index >=
                                                              months.length) {
                                                        return const SizedBox.shrink();
                                                      }

                                                      // ✅ Show every other month to prevent crowding
                                                      if (months.length > 6 &&
                                                          index % 2 != 0) {
                                                        return const SizedBox.shrink();
                                                      }

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 8.0,
                                                            ),
                                                        child: Transform.rotate(
                                                          angle:
                                                              -0.5, // ✅ Rotate text for better fit
                                                          child: Text(
                                                            _formatMonth(
                                                              months[index],
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize:
                                                        50, // ✅ More space for currency
                                                    interval: maxValue > 1000
                                                        ? (maxValue / 4)
                                                              .ceilToDouble()
                                                        : null,
                                                    getTitlesWidget: (value, meta) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              right: 8.0,
                                                            ),
                                                        child: Text(
                                                          _formatCurrency(
                                                            value,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 9,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                                topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                              ),
                                              borderData: FlBorderData(
                                                show: true,
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                  width: 1,
                                                ),
                                              ),
                                              // ✅ Fixed bar groups with proper sorting
                                              barGroups: sortedEntries.asMap().entries.map((
                                                entry,
                                              ) {
                                                final index = entry.key;
                                                final value = entry.value.value;

                                                return BarChartGroupData(
                                                  x: index,
                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: value,
                                                      color:
                                                          Colors.green.shade600,
                                                      width: months.length > 8
                                                          ? 16
                                                          : 20, // ✅ Adjust width based on data count
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      // ✅ Add gradient effect
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        end:
                                                            Alignment.topCenter,
                                                        colors: [
                                                          Colors.green.shade400,
                                                          Colors.green.shade600,
                                                        ],
                                                      ),
                                                      // ✅ Add shadow for better visual
                                                      backDrawRodData:
                                                          BackgroundBarChartRodData(
                                                            show: true,
                                                            toY: maxValue * 1.2,
                                                            color: Colors
                                                                .grey
                                                                .shade100,
                                                          ),
                                                    ),
                                                  ],
                                                  // ✅ Add value labels on top of bars
                                                  showingTooltipIndicators: [],
                                                );
                                              }).toList(),
                                              // ✅ Add touch interaction
                                              barTouchData: BarTouchData(
                                                enabled: true,
                                                touchTooltipData: BarTouchTooltipData(
                                                  getTooltipItem:
                                                      (
                                                        group,
                                                        groupIndex,
                                                        rod,
                                                        rodIndex,
                                                      ) {
                                                        if (groupIndex >=
                                                            months.length)
                                                          return null;

                                                        return BarTooltipItem(
                                                          '${months[groupIndex]}\n${_formatCurrency(rod.toY)}',
                                                          const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 12,
                                                          ),
                                                        );
                                                      },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ✅ Course Breakdown Pie Chart
                      Card(
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
                                "Course Breakdown",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 200,
                                      child:
                                          (totalTDC +
                                                  totalPDC +
                                                  totalRefresher) ==
                                              0
                                          ? Center(
                                              child: Text(
                                                "No course data available",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            )
                                          : PieChart(
                                              PieChartData(
                                                sectionsSpace: 2,
                                                centerSpaceRadius: 40,
                                                sections: [
                                                  if (totalTDC > 0)
                                                    PieChartSectionData(
                                                      color: Colors.indigo,
                                                      value: totalTDC
                                                          .toDouble(),
                                                      title: '$totalTDC',
                                                      radius: 80,
                                                      titleStyle: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  if (totalPDC > 0)
                                                    PieChartSectionData(
                                                      color: Colors.teal,
                                                      value: totalPDC
                                                          .toDouble(),
                                                      title: '$totalPDC',
                                                      radius: 80,
                                                      titleStyle: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  if (totalRefresher > 0)
                                                    PieChartSectionData(
                                                      color: Colors.orange,
                                                      value: totalRefresher
                                                          .toDouble(),
                                                      title: '$totalRefresher',
                                                      radius: 80,
                                                      titleStyle: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (totalTDC > 0)
                                          _buildLegendItem(
                                            color: Colors.indigo,
                                            label: "TDC",
                                            value: totalTDC,
                                          ),
                                        if (totalPDC > 0)
                                          _buildLegendItem(
                                            color: Colors.teal,
                                            label: "PDC",
                                            value: totalPDC,
                                          ),
                                        if (totalRefresher > 0)
                                          _buildLegendItem(
                                            color: Colors.orange,
                                            label: "Refresher",
                                            value: totalRefresher,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '$value students',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class card extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;
  final Color color;

  const card({
    super.key,
    required this.number,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
