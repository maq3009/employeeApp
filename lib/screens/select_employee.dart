import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class SelectEmployeeScreen extends StatefulWidget {
  const SelectEmployeeScreen({Key? key}) : super(key: key);

  @override
  State<SelectEmployeeScreen> createState() => _SelectEmployeeScreenState();
}

class _SelectEmployeeScreenState extends State<SelectEmployeeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Method to fetch employee data
  Future<List<Map<String, dynamic>>> _fetchEmployees() async {
    final snapshot = await supabase
        .from('employees') // Specify the table you want to fetch data from
        .select('*') // Select all columns
        ; // Executes the request to Supabase

    if (snapshot.isNotEmpty) {
      return List<Map<String, dynamic>>.from(snapshot);
    } else {
      throw Exception('Failed to load employees');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Employee'),
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEmployees(), // Fetch employee data
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Show loading spinner
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}', // Show error if it occurs
                style: const TextStyle(fontSize: 18),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // If data is available, display the employee names as buttons
            final employees = snapshot.data!;
            return ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                final employeeName = employee['name'];
                final employeeId = employee['id'];

                return ListTile(
                  title: ElevatedButton(
                    onPressed: () {
                      // Navigate to the AdminCalendarScreen with the selected employee's data
                      Navigator.pushNamed(
                        context,
                        '/adminCalendar',
                        arguments: {
                          'employeeId': employeeId,
                          'employeeName': employeeName,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      employeeName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            );
          } else {
            // If no data, display a message
            return const Center(
              child: Text(
                "No employees found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }
}
