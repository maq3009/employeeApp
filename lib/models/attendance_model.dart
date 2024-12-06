class AttendanceModel {
  final String id;
  final String date;
  final String checkIn;
  final String? checkOut;
  final DateTime createdAt;
  final Map? checkInLocation;
  final Map? checkOutLocation;

  AttendanceModel({
    required this.id,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.createdAt,
    this.checkInLocation,
    this.checkOutLocation,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> data) {
    return AttendanceModel(
      id: data['employee_id'],
      date: data['date'],
      checkIn: data['check_in'] as String,
      checkOut: data['check_out'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      checkInLocation: data['check_in_location'],
      checkOutLocation: data['check_out_location'],
    
    );
  }
}
