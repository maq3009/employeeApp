import 'package:employee_attendance/constants/constants.dart';
import 'package:employee_attendance/models/attendance_model.dart';
import 'package:employee_attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  AttendanceModel? attendanceModel;

  String todayDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

  // Private field for isLoading
  bool _isLoading = false;

  // Getter for isLoading
  bool get isLoading => _isLoading;

  // Setter for isLoading
  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetches today's attendance record for the current user
  Future getTodayAttendance() async {
    try {
      final List result = await _supabase
          .from(Constants.attendanceTable)
          .select()
          .eq("employee_id", _supabase.auth.currentUser!.id)
          .eq('date', todayDate);

      if (result.isNotEmpty) {
        attendanceModel = AttendanceModel.fromJson(result.first);
      } else {
        attendanceModel = null; // Reset if no data is found
      }

      print('Updated AttendanceModel: $attendanceModel'); // Debug print
      notifyListeners(); // Notify the UI
    } catch (error) {
      print('Error fetching attendance: $error');
    }
  }

  /// Handles Check-In and Check-Out actions
  Future markAttendance(BuildContext context) async {
    try {
      final String currentUserId = _supabase.auth.currentUser!.id;

      // Check if employee exists in Enfermeras table
      final employee = await _supabase
          .from('Enfermeras')
          .select('id')
          .eq('id', currentUserId)
          .single();

      if (employee == null) {
        Utils.showSnackBar(
            "Employee record not found in Enfermeras table.", context,
            color: Colors.red);
        return;
      }

      if (attendanceModel?.checkIn == null) {
        // Perform Check-In
        await _supabase.from(Constants.attendanceTable).insert({
          'id': currentUserId, // Set 'id' to currentUserId as it was removed from auto-generation
          'employee_id': currentUserId, // Use employee_id from Enfermeras
          'date': todayDate,
          'check_in': DateFormat('HH:mm').format(DateTime.now()),
        });

        print('Check-In Successful');
      } else if (attendanceModel?.checkOut == null) {
        // Perform Check-Out
        await _supabase
            .from(Constants.attendanceTable)
            .update({
              'check_out': DateFormat('HH:mm').format(DateTime.now()),
            })
            .eq('employee_id', currentUserId)
            .eq('date', todayDate);

        print('Check-Out Successful');
      } else {
        Utils.showSnackBar(
            "Check-Out already completed for today", context,
            color: Colors.blue);
      }

      // Refresh today's attendance after marking attendance
      getTodayAttendance();
    } catch (error) {
      print('Error during markAttendance: $error');
      Utils.showSnackBar("An error occurred. Please try again.", context,
          color: Colors.red);
    }
  }
}
