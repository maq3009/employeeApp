import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:employee_attendance/services/attendance_service.dart';
import 'package:employee_attendance/models/attendance_model.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

class AdminCalendarScreen extends StatefulWidget {
  final String? employeeId;
  final String? employeeName;

  const AdminCalendarScreen({
    Key? key,
    this.employeeId,
    this.employeeName,
  }) : super(key: key);

  @override
  State<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  String selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final attendanceService = Provider.of<AttendanceService>(context);
    final employeeId = widget.employeeId ?? 'admin123'; // Fallback admin ID
    final employeeName = widget.employeeName ?? 'Admin User'; // Fallback admin name

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance for $employeeName"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                selectedMonth,
                style: const TextStyle(fontSize: 18),
              ),
              OutlinedButton(
                onPressed: () async {
                  final selectedDate = await SimpleMonthYearPicker.showMonthYearPickerDialog(
                    context: context,
                    disableFuture: true,
                  );
                  if (selectedDate != null) {
                    setState(() {
                      selectedMonth = DateFormat('MMMM yyyy').format(selectedDate);
                    });
                  }
                },
                child: const Text("Choose Month"),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<AttendanceModel>>(
              future: attendanceService.getEmployeeAttendanceHistory(employeeId, selectedMonth),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final attendance = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            DateFormat('EEE, dd MMM yyyy').format(attendance.createdAt),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Check In: ${attendance.checkIn}"),
                              Text("Check Out: ${attendance.checkOut ?? '--/--'}"),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No data available."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
