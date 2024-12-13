import 'dart:math';
import 'package:employee_attendance/constants/constants.dart';
import 'package:employee_attendance/models/attendance_model.dart';
import 'package:employee_attendance/models/department_model.dart';
import 'package:employee_attendance/models/user_model.dart';
import 'package:employee_attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel?  userModel;
  List<DepartmentModel> allDepartments = [];
  int? employeeDepartment;


  String generateRandomEmployeeId() {
    final random = Random();
    const allChars= 'HogarEstanciasDePaz123456789';
    final randomString = List.generate(8, (index) => allChars[random.nextInt(allChars.length)]).join();
    return randomString;

  }
  Future insertNewUser(String email, String id) async {
    await _supabase.from(Constants.employeeTable).insert({
      'id': id,
      'name': 'name',
      'email': 'email',
      'employee_id': generateRandomEmployeeId(),
      'department': null
    });
  }

  Future<UserModel> getUserData() async {  //psql requests
    final userData = await _supabase
      .from(Constants.employeeTable)
      .select()
      .eq('id', _supabase.auth.currentUser!.id)
      .single();
    userModel = UserModel.fromJson(userData);
    // Since this function can be called multiple times, then it will reset the department value
    // That is why we are using condition to assign only at the first time
    employeeDepartment == null 
      ? employeeDepartment = userModel?.department 
      : null;
    return userModel!;
  } 

  Future<void> getAllDepartments() async {
    final List result =
      await _supabase.from(Constants.departmentTable).select();
    allDepartments = result
      .map((department)  => DepartmentModel.fromJson(department))
      .toList();
    notifyListeners();  
}
  Future updateProfile(String name, BuildContext context) async {
    await _supabase.from(Constants.employeeTable).update({
      'name': name,
      'department': employeeDepartment,
    }).eq('id', _supabase.auth.currentUser!.id);

    Utils.showSnackBar("Profile Updated Succesfully", context,
    color: Colors.green);
    notifyListeners();
  }
  Future<List<UserModel>> getAllEmployees() async {
  try {
    // Fetch all employees from the employee table
    final List response = await _supabase.from(Constants.employeeTable).select();

    // Map the response data to a list of UserModel objects
    return response.map((e) => UserModel.fromJson(e)).toList();
  } catch (e) {
    debugPrint("Error fetching employees: $e");
    return [];
    }
  }
  Future<List<AttendanceModel>> getAttendanceForEmployee(String employeeId, String month) async {
  try {
    final List response = await _supabase
        .from(Constants.attendanceTable) // Replace with your actual attendance table name
        .select()
        .eq('employee_id', employeeId)
        .ilike('date', '$month%');
    return response.map((e) => AttendanceModel.fromJson(e)).toList();
  } catch (e) {
    debugPrint("Error fetching attendance: $e");
    return [];
  }
}
}