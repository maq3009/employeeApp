// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:employee_attendance/services/attendance_service.dart';
// import 'admin_calendar_screen.dart';

// class EmployeeListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final attendanceService = Provider.of<AttendanceService>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Employee List'),
//         backgroundColor: Colors.blueGrey,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: attendanceService.getAllEmployees(), // Fetch employees from database
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No employees found."));
//           }

//           final employees = snapshot.data!;
//           return ListView.builder(
//             itemCount: employees.length,
//             itemBuilder: (context, index) {
//               final employee = employees[index];
//               return ListTile(
//                 title: Text(employee['employeeName']),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AdminCalendarScreen(
//                         employeeId: employee['employeeId'],
//                         arguments: {'employeeName': employee['employeeName']},
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
