/*
  this is my firebase_auth_repo.dart

  Firebase Backend
*/


import 'package:firebase_auth/firebase_auth.dart';
import 'package:mental_health_app/features/auth/domain/entities/app_user.dart';
import 'package:mental_health_app/features/auth/domain/repos/auth_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class FirebaseAuthRepo implements AuthRepo{

  /// access to firebase
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;



  // Login with email and password
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // 1️⃣ Sign in with Firebase Auth
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // 2️⃣ Fetch user data from Firestore
      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception('User data not found in Firestore');
      }

      final user = AppUser.fromJson(doc.data() as Map<String, dynamic>);

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }


  // Registration with email and password
  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async{
    try{
      // 1 Create user in Firebase Auth
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2 Create AppUser object // error line
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email, name: name);

      // 3 Save user to Firestore
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name, // store the name here
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    }catch(e){
      throw Exception('Registration failed: $e');
    }
  }



  //  Delete Account
  @override
  Future<void> deleteAccount() async {
    try{
      // get current user
      final user = firebaseAuth.currentUser;
      //check if user is logged in
      if(user == null) throw Exception('User not found....');
      // delete account
      await user.delete();
      // logout user
      await logout();
    }catch(e){
      throw Exception('Failed to delete account: $e');
    }
  }


  // Get current user
  @override
  @override
  Future<AppUser?> getCurrentUser() async{
    final firebaseUser = firebaseAuth.currentUser;
    if(firebaseUser == null) return null;

    // Fetch from Firestore
    DocumentSnapshot doc = await firestore.collection('users').doc(firebaseUser.uid).get();
    if(!doc.exists) return null;

    return AppUser.fromJson(doc.data() as Map<String, dynamic>);
  }


  // Logout
  @override
  Future<void> logout() async{
    await firebaseAuth.signOut();
  }

  // Password Reset
  @override
  Future<String> sendPasswordResetEmail(String email) async{
    try{
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your email inbox";
    }catch(e){
      return "An error occurred: $e";
    }
  }

}





/*
  this is my firebase_auth_repo.dart

  Firebase Backend

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mental_health_app/features/auth/domain/entities/app_user.dart';
import 'package:mental_health_app/features/auth/domain/repos/auth_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class FirebaseAuthRepo implements AuthRepo{

  /// access to firebase
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;



  // Login with email and password
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try{
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // create user
      AppUser user =AppUser(uid: userCredential.user!.uid,
          email: email);

      return user;
    }catch(e){
      throw Exception('Login failed: $e');
    }
  }

  // Registration with email and password
  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async{
    try{
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);
      return user;
    }catch(e){
      throw Exception('Registration failed: $e');
    }
  }


  //  Delete Account
  @override
  Future<void> deleteAccount() async {
    try{
      // get current user
      final user = firebaseAuth.currentUser;
      //check if user is logged in
      if(user == null) throw Exception('User not found....');
      // delete account
      await user.delete();
      // logout user
      await logout();
    }catch(e){
      throw Exception('Failed to delete account: $e');
    }
  }


  // Get current user
  @override
  Future<AppUser?> getCurrentUser() async{

      // get current logged in user from firebase
      final firebaseUser = firebaseAuth.currentUser;

      // no logged in user
      if(firebaseUser == null) return null;


      // logged in user exists
      return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!);

  }

  // Logout
  @override
  Future<void> logout() async{
    await firebaseAuth.signOut();
  }

  // Password Reset
  @override
  Future<String> sendPasswordResetEmail(String email) async{
    try{
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your email inbox";
    }catch(e){
      return "An error occurred: $e";
    }
  }

}


 */