class AttendanceModel {
  final String id;
  final String date;
  final String checkIn;
  final String? checkOut;
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> data) {
    return AttendanceModel(
      id: data['employee_id'] as String,
      date: data['date'] as String,
      checkIn: data['check_in'] as String,
      checkOut: data['check_out'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}
