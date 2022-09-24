import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

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
          const Text(
              "We've send you an email verification. Please open to verify you account."),
          const Text("Press the button if you haven't received the email."),
          const Text('Please verify your e-mail address:'),
          TextButton(
            onPressed: () async {
              FirebaseAuth auth = FirebaseAuth.instance;
              final user = auth.currentUser;
              await user?.sendEmailVerification();
            },
            child: const Text('Send e-mail verification'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
