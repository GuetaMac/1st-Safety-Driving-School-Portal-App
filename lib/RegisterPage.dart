import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  bool showPassword = false;
  bool showRetypePassword = false;
  bool isLoading = false;

  String name = '';
  String email = '';
  String password = '';
  String retypePassword = '';

  Future<void> handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (password != retypePassword) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Error'),
            content: Text('Passwords do not match!'),
          ),
        );
        return;
      }

      setState(() => isLoading = true);

      try {
        // Create user in Firebase Auth
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            );

        // Save additional user data to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful')),
        );
        Navigator.pushNamed(context, '/'); // Redirect to login/home
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf9f5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset("assets/logo.png", height: 80),
                  const SizedBox(height: 16),
                  const Text(
                    "1st SAFETY DRIVING SCHOOL",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  const Text("Join us and start your driving journey!"),
                  const SizedBox(height: 24),

                  // Full Name
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => name = val,
                    validator: (val) => val!.isEmpty ? 'Enter full name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => email = val,
                    validator: (val) =>
                        val!.contains('@') ? null : 'Enter valid email',
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                    ),
                    onChanged: (val) => password = val,
                    validator: (val) => val!.length < 6 ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 16),

                  // Retype Password
                  TextFormField(
                    obscureText: !showRetypePassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showRetypePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => showRetypePassword = !showRetypePassword,
                        ),
                      ),
                    ),
                    onChanged: (val) => retypePassword = val,
                    validator: (val) =>
                        val!.isEmpty ? 'Re-type password' : null,
                  ),
                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Redirect
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    child: const Text('Already have an account? Sign in here'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
