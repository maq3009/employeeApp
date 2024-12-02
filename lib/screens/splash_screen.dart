import 'package:employee_attendance/screens/home_screen.dart';
import 'package:employee_attendance/screens/login_screen.dart';
import 'package:employee_attendance/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // authService.signOut();


    return authService.currentUser == null
        ? const LoginScreen() 
        : const HomeScreen();
  }
}