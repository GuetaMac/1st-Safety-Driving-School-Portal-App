import 'package:final_app/admin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <-- importante ito
import 'LoginPage.dart';
import 'RegisterPage.dart';
import 'StudentPage.dart';
import 'manager.dart'; // Import the manager dashboard page
import 'instructor.dart'; // Import the instructor dashboard page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <-- gumamit nito
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1st Safety',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/student': (_) => const StudentDashboard(),
        '/admin_dashboard': (_) => const Admin(),
        '/instructor_dashboard': (context) => const InstructorDashboardPage(),
        '/manager_dashboard': (context) => const ManagerDashboardPage(),
      },
    );
  }
}
