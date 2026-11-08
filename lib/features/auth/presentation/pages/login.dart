/*
* LOGIN PAGE UI
* user can login in using: email and password
* once successfully logged in, they will be directed to the home page
*
* */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/button.dart';
import '../components/facebook_button.dart';
import '../components/google_button.dart';
import '../components/textfield.dart';
import '../cubits/auth_cubit.dart';

class Login extends StatefulWidget {
  final void Function()? togglePages;

  const Login({super.key, required this.togglePages});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Text Controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  // auth cubit
  late final authCubit = context.read<AuthCubit>();

  // register button pressed
  void login() {
    // prepare email and password
    final String email = emailController.text;
    final String pw = pwController.text;

    // ensure that all fields are field
    if (email.isNotEmpty && pw.isNotEmpty) {
      // login
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
    }
  }

  // forgot password box
  void openForgotPasswordBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Forgot Password?"),
        content: MyTextfield(
          controller: emailController,
          hintText: "Enter email...",
          obscureText: false,
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          // reset button
          TextButton(
            onPressed: () async {
              String message = await authCubit.forgotPassword(
                emailController.text,
              );

              if (message ==
                  "Password reset email sent! Check your email inbox") {
                Navigator.pop(context);
                emailController.clear();
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // BODY
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              left: 25.0,
              right: 25.0,
              top: MediaQuery.of(context).padding.top + 25.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 25.0, // Adjust for keyboard
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                Icon(
                  Icons.self_improvement,
                  size: 80.0,
                  color: Theme.of(context).colorScheme.primary,
                ),

                SizedBox(height: 25.0),
                // Name of the app
                Text(
                  "M I N D  H A V E N",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(height: 25.0),

                // Email Text Field
                MyTextfield(
                  controller: emailController,
                  hintText: 'Enter email',
                  obscureText: false,
                ),

                SizedBox(height: 15.0),

                // Password Text Field
                MyTextfield(
                  controller: pwController,
                  hintText: 'Enter password',
                  obscureText: true,
                ),
                SizedBox(height: 10.0),

                // Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => openForgotPasswordBox(),
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Login Button
                SizedBox(height: 25.0),
                MyButton(onTap: login, text: "LOGIN"),

                SizedBox(height: 25.0),
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text("Or Sign in with"),
                    ),
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                // Sign in with other options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // google
                    GoogleButton(),

                    // facebook
                    FacebookButton(),
                  ],
                ),

                // Don't have an account
                SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        " Register now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
