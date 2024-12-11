import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innovators/phone_login/dialogbox.dart';

class PhoneLoginServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> phoneSignIn(
    BuildContext context,
    String phoneNumber,
  ) async {
    // Controller for OTP input
    TextEditingController codeController = TextEditingController();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto sign-in logic
          await _auth.signInWithCredential(credential);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Phone number verified and signed in!')),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle verification failure
          String errorMessage = e.message ?? 'Verification failed. Try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Show OTP dialog
          showOTPDialog(
            context: context,
            codeController: codeController,
            onPressed: () async {
              try {
                // Retrieve credential from the OTP entered
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: verificationId,
                  smsCode: codeController.text.trim(),
                );

                // Sign in with the credential
                await _auth.signInWithCredential(credential);

                // Dismiss the OTP dialog and show success message
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully signed in!')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Code auto-retrieval timeout logic
          debugPrint('Code auto-retrieval timeout for $verificationId');
        },
      );
    } catch (e) {
      // Handle unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
