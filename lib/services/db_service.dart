import 'dart:math';
import 'package:employee_attendance/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  String generateRandomEmployeeId() {
    final random = Random();
    const allChars= 'HogarEstanciasDePaz123456789';
    final randomString = List.generate(8, (index) => allChars[random.nextInt(allChars.length)]).join();
    return randomString;

  }
  Future insertNewUser(String email, String id) async {
    await _supabase.from(Constants.employeeTable).insert({
      'id': id,
      'name': '',
      'email': 'email',
      'employee_id': generateRandomEmployeeId(),
      'department': null
    });
  }
}