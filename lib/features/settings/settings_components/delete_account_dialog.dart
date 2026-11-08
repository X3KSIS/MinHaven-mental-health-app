import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/cubits/auth_cubit.dart';

class DeleteAccountDialog extends StatelessWidget {
  final FirebaseFirestore firestore;
  final Color primaryColor;

  const DeleteAccountDialog({
    super.key,
    required this.firestore,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[700]),
          const SizedBox(width: 12),
          Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you sure you want to delete your account?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This action cannot be undone. All your data including:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildWarningItem('Chat history'),
          _buildWarningItem('Journal entries'),
          _buildWarningItem('Mood tracking data'),
          _buildWarningItem('Profile information'),
          const SizedBox(height: 12),
          const Text(
            'will be permanently deleted.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        TextButton(
          onPressed: () => _deleteAccount(context),
          child: const Text(
            'Delete',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.close, size: 16, color: Colors.red[700]),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    Navigator.pop(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).delete();
        await context.read<AuthCubit>().deleteAccount();
      }
      // Close loading dialog
      Navigator.pop(context);
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}