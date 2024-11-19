import 'package:employee_attendance/screens/home_screen.dart';
import 'package:employee_attendance/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './login_screen.dart';



class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    // authService.signOut();
    return authService.currentUser == null ? const LoginScreen() : const HomeScreen();
  }
}