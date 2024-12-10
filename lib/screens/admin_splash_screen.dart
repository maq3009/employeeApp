import 'package:employee_attendance/screens/admin_home_screen.dart';
import 'package:employee_attendance/screens/admin_login_screen.dart';
import 'package:employee_attendance/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class AdminSplashScreen extends StatelessWidget {
  const AdminSplashScreen({super.key});

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
        ? const AdminLoginScreen() 
        : const AdminHomeScreen();
  }
}