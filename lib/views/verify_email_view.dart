import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify E-mail')),
      body: Column(
        children: [
          const Text('Please verify your e-mail address:'),
          TextButton(
              onPressed: () async {
                FirebaseAuth auth = FirebaseAuth.instance;
                final user = auth.currentUser;
                await user?.sendEmailVerification();
              },
              child: const Text('Send e-mail verification')),
        ],
      ),
    );
  }
}
