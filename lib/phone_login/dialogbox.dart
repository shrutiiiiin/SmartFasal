import 'package:flutter/material.dart';

void showOTPDialog({
  required BuildContext context,
  required TextEditingController codeController,
  required VoidCallback onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible:
        false, // Prevent dismissing the dialog by tapping outside
    builder: (context) => AlertDialog(
      title: const Text('Enter OTP'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter OTP",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onPressed, // Pass the `onPressed` callback
          child: const Text('Done'),
        ),
      ],
    ),
  );
}
