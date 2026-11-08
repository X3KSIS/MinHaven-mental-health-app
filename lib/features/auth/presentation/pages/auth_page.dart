/*
auth_page.dart
  Auth Page determines whether to show the login or register page
 */

import 'package:flutter/material.dart';
import 'package:mental_health_app/features/auth/presentation/pages/login.dart';
import 'package:mental_health_app/features/auth/presentation/pages/register_page.dart';


 class AuthPage extends StatefulWidget {
   const AuthPage({super.key});

   @override
   State<AuthPage> createState() => _AuthPageState();
 }

 class _AuthPageState extends State<AuthPage> {

   // initially, show the login page
   bool showLoginPage = true;

   // toggle between pages
   void togglePages() {
     setState(() {
       showLoginPage =!showLoginPage;
     });
   }

   @override
   Widget build(BuildContext context) {
     if(showLoginPage){
       return Login(
         togglePages: togglePages,
       );
     }else{
       return RegisterPage(
         togglePages: togglePages,
       );
     }
   }
 }


