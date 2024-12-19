import 'package:employee_attendance/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';
import 'package:employee_attendance/models/attendance_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Attendance"),
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
              future: attendanceService.getAttendanceForEmployee(
                attendanceService.currentUserId,
                selectedMonthService,
              ),
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
                    return ListTile(
                      title: Text(DateFormat("EE, MMM dd").format(attendance.createdAt)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Check In: ${attendance.checkIn}"),
                          Text("Check Out: ${attendance.checkOut ?? '--/--'}"),
                        ],
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
