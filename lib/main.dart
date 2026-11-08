import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_app/features/auth/presentation/components/loading.dart';
import 'package:mental_health_app/features/mood_tracker/mood_dashboard.dart';
import 'package:mental_health_app/themes/dark_mode.dart';
import 'package:mental_health_app/themes/light_mode.dart';
import 'features/Home/home.dart';
import 'features/auth/data/firebase_auth_repo.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/cubits/auth_states.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/chatbot/presentation/pages/chat_bot.dart';
import 'features/gamification/data/services/gamification_service.dart';
import 'features/journal/journal.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  /// Firebase Setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize gamification for authenticated users
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      GamificationService().initializeUser(user.uid);
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // provide cubits to the app
      providers: [
        // auth cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        routes: {
          '/home': (context) => const HomeScreen(),
          '/journal': (context) => const JournalScreen(),
          '/mood-insights': (context) => const MoodDashboard(),
          // Note: '/chat' is handled in builder as ChatBot
        },
        home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, state){
              // Show loading during login/signup/initial check
              if (state is AuthLoading) {
                return const LoadingScreen();
              }

              // unauthenticated -> auth page(login/register)
              if(state is Unauthenticated){
                return const AuthPage();
              }

              // authenticated -> home page (ChatBot)
              if(state is Authenticated){
                return const ChatBot();
              }else{
                return const LoadingScreen();
              }
            },
            // listen for state changes
            listener: (context, state){
              if(state is AuthError){

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
            }
        ),
      ),
    );
  }
}