// register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/button.dart';
import '../components/textfield.dart';
import '../cubits/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;

  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text Controllers
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();

  // register button pressed
  void register() {
    // prepare info
    final String name = userNameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    // auth cubit
    final authCubit = context.read<AuthCubit>();

    // ensure fields are not empty
    if (email.isNotEmpty &&
        name.isNotEmpty &&
        pw.isNotEmpty &&
        confirmPw.isNotEmpty) {
      // ensure passwords match
      if (pw == confirmPw) {
        authCubit.register(name, email, pw);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      }
    }else{
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
    }
  }

  // Dispose the controllers to prevent memory leaks
  @override
  void dispose(){
    userNameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  "Find your peace with us, let's create an account",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                SizedBox(height: 25.0),

                // User name Text Field
                MyTextfield(
                  controller: userNameController,
                  hintText: 'username',
                  obscureText: false,
                ),

                SizedBox(height: 15.0),

                // Email Text Field
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                SizedBox(height: 15.0),

                // Password Text Field
                MyTextfield(
                  controller: pwController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: 10.0),

                // confirm password
                MyTextfield(
                  controller: confirmPwController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                // Register Button
                SizedBox(height: 25.0),
                MyButton(
                    onTap:register,
                    text: "SIGN UP"
                ),

                // Sign in with other options

                // have an account?
                SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Do you have an account?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        " Login now",
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
