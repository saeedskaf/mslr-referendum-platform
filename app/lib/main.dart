import 'package:flutter/material.dart';
import 'package:mslr/presentation/screens/auth/admin_login_screen.dart';
import 'package:mslr/presentation/screens/auth/registration_screen.dart';
import 'package:mslr/presentation/screens/auth/splash_screen.dart';
import 'package:mslr/presentation/screens/auth/welcome_screen.dart';
import 'package:mslr/presentation/screens/auth/login_screen.dart';
import 'package:mslr/presentation/screens/ec/admin_dashboard.dart';
import 'package:mslr/presentation/screens/ec/create_referendum_screen.dart';
import 'package:mslr/presentation/screens/ec/edit_referendum_screen.dart';
import 'package:mslr/presentation/screens/voter/voter_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSLR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/voter-dashboard': (context) => const VoterDashboard(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/admin/create-referendum': (context) => const CreateReferendumScreen(),
        '/admin/edit-referendum': (context) => const EditReferendumScreen(),
      },
    );
  }
}
