import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_health_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mental_health_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:mental_health_app/features/auth/presentation/pages/register_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    // Set initial state
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
  });

  Widget makeTestableWidget() {
    return BlocProvider<AuthCubit>.value(
      value: mockAuthCubit,
      child: MaterialApp(
        home: RegisterPage(togglePages: () {}),
      ),
    );
  }

  group('Register Page Tests', () {
    testWidgets('Shows error when any field is empty', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Try to sign up without filling anything
      await tester.tap(find.text("SIGN UP"));
      await tester.pump();

      expect(find.text("All fields are required"), findsOneWidget);
      // Verify register was NEVER called
      verifyNever(() => mockAuthCubit.register(any(), any(), any()));
    });

    testWidgets('Shows error when passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Fill fields but use different passwords
      await tester.enterText(find.widgetWithText(TextField, 'username'), 'JohnDoe');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'john@test.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'different123');

      await tester.tap(find.text("SIGN UP"));
      await tester.pump();

      expect(find.text("Passwords do not match"), findsOneWidget);
      verifyNever(() => mockAuthCubit.register(any(), any(), any()));
    });

    testWidgets('Calls register on Cubit when all fields are valid', (WidgetTester tester) async {
      // Stub the register method
      when(() => mockAuthCubit.register(any(), any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(makeTestableWidget());

      // Fill all fields correctly
      await tester.enterText(find.widgetWithText(TextField, 'username'), 'JohnDoe');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'john@test.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      await tester.tap(find.text("SIGN UP"));
      await tester.pump();

      // Verify cubit received the correct data
      verify(() => mockAuthCubit.register('JohnDoe', 'john@test.com', 'password123')).called(1);
    });

    testWidgets('Tapping "Login now" triggers togglePages', (WidgetTester tester) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: MaterialApp(
            home: RegisterPage(togglePages: () => toggleCalled = true),
          ),
        ),
      );

      await tester.tap(find.text(" Login now"));
      await tester.pump();

      expect(toggleCalled, isTrue);
    });
  });
}