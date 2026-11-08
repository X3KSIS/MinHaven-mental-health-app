import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? bio,
    String? phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'email': email,
      'bio': bio ?? '',
      'phoneNumber': phoneNumber ?? '',
      'updatedAt': DateTime.now(),
    });
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'profilePictureUrl': downloadUrl,
        'updatedAt': DateTime.now(),
      });

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  Future<void> deleteProfilePicture() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
      await ref.delete();

      await _firestore.collection('users').doc(user.uid).update({
        'profilePictureUrl': FieldValue.delete(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error deleting profile picture: $e');
    }
  }

  Stream<Map<String, dynamic>?> getUserProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }
}