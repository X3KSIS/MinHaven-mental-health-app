import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_health_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mental_health_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:mental_health_app/features/auth/presentation/pages/login.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

 // Ensure this path is correct

// 1. Create the Mock using MockCubit
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();

    // 2. Set the initial state for the mock

    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
  });

  // Helper function to wrap the widget with the necessary Provider and Material Parent
  Widget makeTestableWidget() {
    return BlocProvider<AuthCubit>.value(
      value: mockAuthCubit,
      child: MaterialApp(
        home: Login(togglePages: () {}),
      ),
    );
  }

  group('Login Page Widget Tests', () {
    testWidgets('Shows validation error when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Tap Login button
      await tester.tap(find.text("LOGIN"));

      // Re-render to show SnackBar
      await tester.pump();

      expect(find.text("All fields are required"), findsOneWidget);
    });

    testWidgets('Calls login on AuthCubit when credentials are provided', (WidgetTester tester) async {
      // Stub the login method to do nothing when called
      when(() => mockAuthCubit.login(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(makeTestableWidget());

      // Find the text fields.
      // Note: If you use MyTextfield, find.byType(TextField) works if MyTextfield returns one.
      final emailField = find.ancestor(
        of: find.text('Enter email'),
        matching: find.byType(TextField),
      );
      final passwordField = find.ancestor(
        of: find.text('Enter password'),
        matching: find.byType(TextField),
      );

      // Enter data
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      // Tap Login
      await tester.tap(find.text("LOGIN"));
      await tester.pump();

      // Verify the Cubit method was called
      verify(() => mockAuthCubit.login('test@example.com', 'password123')).called(1);
    });

    testWidgets('Opens Forgot Password dialog when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Tap "Forgot password?"
      await tester.tap(find.text("Forgot password?"));

      // pumpAndSettle waits for the dialog animation
      await tester.pumpAndSettle();

      // Check if dialog is visible
      expect(find.text("Forgot Password?"), findsOneWidget);
      expect(find.text("Reset"), findsOneWidget);
    });
  });
}