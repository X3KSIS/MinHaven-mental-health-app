import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/settings_constants.dart';
import '../../../themes/app_colors.dart';

class ClearDataDialog extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String dataType;

  const ClearDataDialog({
    super.key,
    required this.firestore,
    required this.dataType,
  });

  @override
  Widget build(BuildContext context) {
    final info = SettingsConstants.getClearDataTitle(dataType);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        info['title']!,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.textPrimary,
        ),
      ),
      content: Text(
        '${info['message']} This action cannot be undone.',
        style: TextStyle(fontSize: 14, color: context.textFaint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: context.textMuted),
          ),
        ),
        TextButton(
          onPressed: () => _clearData(context),
          child: const Text(
            'Clear',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Future<void> _clearData(BuildContext context) async {
    Navigator.pop(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await firestore
            .collection('users')
            .doc(user.uid)
            .collection(dataType)
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${SettingsConstants.getClearDataTitle(dataType)['title']} completed successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear data: $e')),
      );
    }
  }
}