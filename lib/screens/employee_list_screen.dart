import 'package:flutter/material.dart';
import 'package:employee_attendance/models/user_model.dart';
import 'package:employee_attendance/services/db_service.dart';
import 'package:employee_attendance/screens/admin_calendar_screen.dart';
import 'package:provider/provider.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<UserModel> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    final dbService = Provider.of<DbService>(context, listen: false);
    final fetchedEmployees = await dbService.getAllEmployees();
    setState(() {
      employees = fetchedEmployees;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee List"),
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return ListTile(
                  title: Text(employee.employeeId),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminCalendarScreen(
                          employeeId: employee.employeeId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
