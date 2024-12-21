import 'package:employee_attendance/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';
import 'package:employee_attendance/models/attendance_model.dart';

class AdminCalendarScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;
  final dynamic employeeId;

  const AdminCalendarScreen({
    Key? key,
    required this.arguments,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  late String selectedMonthUI; // For UI display: 'MMMM yyyy'
  late String selectedMonthService; // For service calls: 'yyyy-MM'
  late AttendanceService attendanceService;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonthUI = DateFormat('MMMM yyyy').format(now);
    selectedMonthService = DateFormat('yyyy-MM').format(now);
    attendanceService = Provider.of<AttendanceService>(context, listen: false);
  }

  Future<void> _selectMonth() async {
    final DateTime? pickedDate = await SimpleMonthYearPicker.showMonthYearPickerDialog(
      context: context,
      disableFuture: true,
    );
    if (pickedDate != null) {
      setState(() {
        selectedMonthUI = DateFormat('MMMM yyyy').format(pickedDate);
        selectedMonthService = DateFormat('yyyy-MM').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String employeeName = widget.arguments['employeeName'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance: $employeeName"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMonthUI, // Display in 'MMMM yyyy'
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                OutlinedButton(
                  onPressed: _selectMonth,
                  child: const Text("Select Month"),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AttendanceModel>>(
              future: attendanceService.getAttendanceForEmployee(widget.employeeId, selectedMonthService),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No attendance data for this month."),
                  );
                }

                final attendanceData = snapshot.data!;
                return ListView.builder(
                  itemCount: attendanceData.length,
                  itemBuilder: (context, index) {
                    final attendance = attendanceData[index];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          DateFormat("EE, MMM dd").format(attendance.createdAt),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Check In
                              Row(
                                children: [
                                  const Icon(Icons.login, color: Colors.green, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Check In: ${attendance.checkIn}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Check Out
                              Row(
                                children: [
                                  const Icon(Icons.logout, color: Colors.red, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Check Out: ${attendance.checkOut ?? '--/--'}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Break In
                              Row(
                                children: [
                                  const Icon(Icons.pause_circle_filled, color: Colors.blue, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Break In: ${attendance.breakIn ?? '--/--'}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Break Out
                              Row(
                                children: [
                                  const Icon(Icons.play_circle_filled, color: Colors.orange, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Break Out: ${attendance.breakOut ?? '--/--'}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
