import 'dart:async';

import 'package:employee_attendance/services/db_service.dart';
import 'package:employee_attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DbService _dbService = DbService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  late StreamController<User?> _authStateController;

  AuthService() {
    _authStateController = StreamController<User?>();
    _supabase.auth.onAuthStateChange.listen((authState) {
      //Access the user information through the session property
      final user = authState.session?.user;
      _authStateController.add(user);
    });
  }

  Stream<User?> authStateChanges() {
    return _authStateController.stream;
  }




  /// Registers a new employee
  Future<void> registerEmployee(
    String email, 
    String password, 
    BuildContext context,
  ) async {
    try {
      setIsLoading = true;

      if (email.isEmpty || password.isEmpty) {
        throw Exception("Todos los campos son requeridos");
      }

      final AuthResponse response = 
        await _supabase.auth.signUp(
          email: email,
          password: password,
      );
      await _dbService.insertNewUser(email, response.user!.id); 
      Utils.showSnackBar("Exito ! Ahora puede entrar a la aplicacion", context, 
        color: Colors.green);
      await loginEmployee(email, password, context);
      Navigator.pop(context);

        } catch (e) {
      setIsLoading = false;
      Utils.showSnackBar(e.toString(), context, color: Colors.red);
    }
  }

  /// Logs in an employee
  Future<void> loginEmployee(
    String email, 
    String password, 
    BuildContext context,
  ) async {
    try {
      setIsLoading = true;

      if (email.isEmpty || password.isEmpty) {
        throw Exception("Todos los campos son requeridos");
      }

      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,);
        setIsLoading = false;
        } catch (e) {
        setIsLoading = false;
        Utils.showSnackBar(e.toString(), context, color: Colors.red
        );}
  }
  /// Logs out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }

  Future<void> loginAdmin(
  String email,
  String password,
  BuildContext context,
) async {
  try {
    setIsLoading = true;

    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception("No user found with these credentials.");
    }

    Utils.showSnackBar("Admin login successful!", context, color: Colors.green);

    // Navigate to the admin screen or perform any post-login tasks
    Navigator.pushNamed(context, '/adminCalendar');

  } catch (e) {
    setIsLoading = false;
    Utils.showSnackBar("Admin login failed: ${e.toString()}", context, color: Colors.red);
    debugPrint("Admin login error: $e");
  }
}


  /// Returns the currently signed-in user
  User? get currentUser => _supabase.auth.currentUser;

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
