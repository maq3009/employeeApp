import 'package:employee_attendance/constants/constants.dart';
import 'package:employee_attendance/models/attendance_model.dart';
import 'package:employee_attendance/models/user_model.dart';
import 'package:employee_attendance/services/location_service.dart';
import 'package:employee_attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  AttendanceModel? attendanceModel;

  String todayDate = DateFormat("dd MMMM yyyy").format(DateTime.now());
  bool _isLoading = false;

  get currentUserId {
  return Supabase.instance.client.auth.currentUser?.id;
}

  bool get isLoading => _isLoading;

  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _attendanceHistoryMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  String get attendanceHistoryMonth => _attendanceHistoryMonth;

  set attendanceHistoryMonth(String value) {
    _attendanceHistoryMonth = value;
    notifyListeners();
  }

  bool _isAdminMode = false;
  String? _selectedEmployeeId;

  void setAdminMode(String employeeId) {
    _isAdminMode = true;
    _selectedEmployeeId = employeeId;
    notifyListeners();
  }

  void resetAdminMode() {
    _isAdminMode = false;
    _selectedEmployeeId = null;
    notifyListeners();
  }

  void resetAttendance() {
    attendanceModel = null;
    notifyListeners();
  }

  Future getTodayAttendance() async {
    final List result = await _supabase
        .from(Constants.attendanceTable)
        .select()
        .eq('employee_id', _supabase.auth.currentUser!.id)
        .eq('date', todayDate);
    if (result.isNotEmpty) {
      attendanceModel = AttendanceModel.fromJson(result.first);
    }
    notifyListeners();
  }

  Future<List<AttendanceModel>> getAttendanceHistory() async {
    if (_isAdminMode && _selectedEmployeeId != null) {
      return getAttendanceForEmployee(_selectedEmployeeId!, _attendanceHistoryMonth);
    } else {
      return getAttendanceForEmployee(_supabase.auth.currentUser!.id, _attendanceHistoryMonth);
    }
  }

  void setAttendanceHistoryMonth(String month) {
    _attendanceHistoryMonth = month;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final result = await _supabase.from('employees').select();
    return List<Map<String, dynamic>>.from(result);
  }

Future<List<UserModel>> getEmployees() async {
  final url = Uri.parse('https://yourapiurl.com/employees');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Employees data: $data');  // Debugging line
      return data.map((item) => UserModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  } catch (e) {
    throw Exception('Error fetching employees: $e');
  }
}


Future<List<AttendanceModel>> getAttendanceForEmployee(String employeeId, String month) async {
  try {
    // Extract the month and year in the correct format
    final DateTime parsedMonth = DateFormat('yyyy-MM').parse(month);
    final String monthYear = DateFormat('MMMM yyyy').format(parsedMonth); // e.g., "December 2024"

    // Query Supabase
    final result = await _supabase
        .from(Constants.attendanceTable)
        .select()
        .eq('employee_id', employeeId) // Match employee_id
        .like('date', '%$monthYear%') // Match dates ending with "MMMM yyyy"
        .order('created_at', ascending: true);

    // Convert result to a list of AttendanceModel
    return List<Map<String, dynamic>>.from(result).map((data) {
      return AttendanceModel.fromJson(data);
    }).toList();
  } catch (e) {
    throw Exception('Error fetching attendance data: $e');
  }
}








  Future markAttendance(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime checkInTimeLimit = DateTime(now.year, now.month, now.day, 23, 0);
    DateTime checkOutLimit = DateTime(now.year, now.month, now.day, 0, 0);

    Map? getLocation = await LocationService().initializeAndGetLocation(context);
    if (getLocation != null) {
      if (attendanceModel?.checkIn == null) {
        if (now.isAfter(checkInTimeLimit)) {
          Utils.showSnackBar("It is past check-in time, better try tomorrow", context);
          return;
        } else {
          await _supabase.from(Constants.attendanceTable).insert({
            "employee_id": _supabase.auth.currentUser!.id,
            "date": todayDate,
            "check_in": DateFormat('HH:mm').format(DateTime.now()),
            "check_in_location": getLocation,
          });
        }
      } else if (attendanceModel?.checkOut == null) {
        if (now.isBefore(checkOutLimit)) {
          Utils.showSnackBar("It is too early to check out, Try after 04:30 PM", context);
          return;
        } else {
          await _supabase
              .from(Constants.attendanceTable)
              .update({
                'check_out': DateFormat('HH:mm').format(DateTime.now()),
                'check_out_location': getLocation
              })
              .eq('employee_id', _supabase.auth.currentUser!.id)
              .eq('date', todayDate);
        }
      } else {
        Utils.showSnackBar("You have already checked out today!", context);
      }
      getTodayAttendance();
    } else {
      Utils.showSnackBar("Location not accessible at the moment, please try again later", context, color: Colors.redAccent);
      getTodayAttendance();
    }
  }
}