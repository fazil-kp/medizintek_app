import 'package:flutter/material.dart';

class ExitConfirmationDialog {
  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Prevent dismissing by tapping outside
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Exit App',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              content: const Text('Are you sure you want to exit the app?', style: TextStyle(color: Colors.black87, fontSize: 16)),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Don't exit
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true), // Exit app
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF129247),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Exit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }
}
