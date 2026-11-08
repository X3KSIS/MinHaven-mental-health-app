


/* auth_cubit.dart
Responsible for state management


 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mental_health_app/features/auth/domain/entities/app_user.dart';
import 'package:mental_health_app/features/auth/domain/repos/auth_repo.dart';
import 'package:mental_health_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'auth_states.dart';

class AuthCubit extends Cubit<AuthState>{
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  // get current user
  AppUser? get currentUser => _currentUser;

  // check if user is authenticate
  void checkAuth() async{
    emit(AuthLoading());

    // get current user
    final AppUser? user = await authRepo.getCurrentUser();
    if(user != null){
      _currentUser = user;
      emit(Authenticated(user));
    }else{
      emit(Unauthenticated());
    }
  }

  // logging with email and password
  Future<void> login(String email, String pw) async{
    try{
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);

      if(user != null){
        _currentUser = user;
        emit(Authenticated(user));
      }else{
        emit(Unauthenticated());
      }
    }catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // Register with email and password
  Future<void> register(String name, String email, String pw) async{
    try{
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);

      if(user != null){
        _currentUser = user;
        emit(Authenticated(user));
      }else{
        emit(Unauthenticated());
      }
    }catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // logout
  Future<void> logout() async{
    emit(AuthLoading());
    await authRepo.logout();
    emit(Unauthenticated());
  }

  // forgot password
  Future<String> forgotPassword(String email) async{
    try{
      final message = await authRepo.sendPasswordResetEmail(email);
      return message;
    }catch(e){
      return e.toString();

    }
  }

  Future<void> refreshUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        // Update your state with new user data
        // This depends on your AuthCubit implementation
      }
    }
  }

  // delete account
  Future<void> deleteAccount() async{
    try{
      emit(AuthLoading());
      await authRepo.deleteAccount();
      emit(Unauthenticated());
    }catch(e){
      emit(AuthError(e.toString()));
    }
  }
}
