import 'package:intl/intl.dart';

class AttendanceModel {
  final String id;
  final String date;
  final String checkIn;
  final String? checkOut;
  final DateTime createdAt;
  final Map? checkInLocation;
  final Map? checkOutLocation;
  final String? breakIn;
  final String? breakOut;

  AttendanceModel({
    required this.id,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.createdAt,
    this.checkInLocation,
    this.checkOutLocation,
    this.breakIn,
    this.breakOut,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> data) {
    final rawBreakIn = data['break_in'] as String?;
    String? formattedBreakIn;

    if (rawBreakIn != null) {
      try {
        // Attempt to parse the rawBreakIn as a DateTime
        final dt = DateTime.parse(rawBreakIn);
        // If successful, format it to HH:mm
        formattedBreakIn = DateFormat('HH:mm').format(dt);
      } catch (e) {
        // If parsing fails, keep it as is
        formattedBreakIn = rawBreakIn;
      }
    }

    return AttendanceModel(
      id: data['employee_id'],
      date: data['date'],
      checkIn: data['check_in'] as String,
      checkOut: data['check_out'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      checkInLocation: data['check_in_location'],
      checkOutLocation: data['check_out_location'],
      breakIn: formattedBreakIn,
      breakOut: data['break_out'] as String?,
    );
  }
}
