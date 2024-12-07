import 'package:employee_attendance/constants/constants.dart';
import 'package:employee_attendance/models/attendance_model.dart';
import 'package:employee_attendance/services/location_service.dart';
import 'package:employee_attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:location/location.dart';


class AttendanceService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  AttendanceModel? attendanceModel;

  String todayDate = DateFormat("dd MMMM yyyy").format(DateTime.now());

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _attendanceHistoryMonth =
      DateFormat('MMMM yyyy').format(DateTime.now());

  String get attendanceHistoryMonth => _attendanceHistoryMonth;

  set attendanceHistoryMonth(String value) {
    _attendanceHistoryMonth = value;
    notifyListeners();
  }

  void resetAttendance() {
    // Reset your attendance data here
    attendanceModel = null;

    // Notify listeners to update the UI
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

  Future markAttendance(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime checkInTimeLimit = DateTime(now.year, now.month, now.day, 23, 0);
    DateTime checkOutLimit = DateTime(now.year, now.month, now.day, 0, 0);

    Map? getLocation =
        await LocationService().initializeAndGetLocation(context);
    if (getLocation != null) 
    {
      if (attendanceModel?.checkIn == null) {
        if (now.isAfter(checkInTimeLimit)) {
          Utils.showSnackBar(
              "It is past check-in time, better try tomorrow", context);
          return;
        } else 
        {
          await _supabase.from(Constants.attendanceTable).insert({
            "employee_id": _supabase.auth.currentUser!.id,
            "date": todayDate,
            "check_in": DateFormat('HH:mm').format(DateTime.now()),
            "check_in_location": getLocation,
          });
        }
      } else if (attendanceModel?.checkOut == null) {
        if (now.isBefore(checkOutLimit)) {
          Utils.showSnackBar(
              "It is too early to check out, Try after 04:30 PM", context);
          return;
        } else {
          await _supabase
              .from(Constants.attendanceTable)
              .update({
                'check_out': DateFormat('HH:mm').format(DateTime.now()),
                'check_out_location': getLocation})
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

  Future<List<AttendanceModel>> getAttendanceHistory() async {
    final List data = await _supabase
        .from(Constants.attendanceTable)
        .select()
        .eq('employee_id', _supabase.auth.currentUser!.id)
        .textSearch('date', "'$attendanceHistoryMonth'", config: 'english')
        .order('created_at', ascending: false);

    return data
        .map((attendance) => AttendanceModel.fromJson(attendance))
        .toList();
  }
}