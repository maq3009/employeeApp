import 'package:employee_attendance/screens/admin_calendar_screen.dart';
import 'package:employee_attendance/screens/admin_employee_management_screen.dart';
import 'package:employee_attendance/screens/profile_screen.dart';
import 'package:employee_attendance/models/user_model.dart';
import 'package:employee_attendance/services/db_service.dart';
import 'package:employee_attendance/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const AdminCalendarScreen(arguments: {}, employeeId: ''),
    const AdminEmployeeScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.userGroup,
    FontAwesomeIcons.user,
  ];

  final List<String> titles = [
    "Admin Calendar",
    "Manage Employees",
    "Admin Profile",
  ];

  Future<void> _handleBackButton() async {
    final confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout and return to the login screen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DbService>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        await _handleBackButton();
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[currentIndex]),
          backgroundColor: Colors.blueGrey,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _handleBackButton();
            },
          ),
        ),
        body: currentIndex == 0
            ? FutureBuilder<List<UserModel>>(
                future: dbService.getAllEmployees(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No employees found."),
                    );
                  }

                  final employees = snapshot.data!;
                  return ListView.builder(
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: Text(
                              employee.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            employee.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text("Employee ID: ${employee.employeeId}"),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/adminCalendar',
                              arguments: {
                                'employeeId': employee.id,
                                'employeeName': employee.name,
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              )
            : IndexedStack(
                index: currentIndex,
                children: screens,
              ),
        bottomNavigationBar: Container(
          height: 70,
          margin: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(40)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < navigationIcons.length; i++) ...{
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      currentIndex = i;
                    }),
                    child: Center(
                      child: FaIcon(
                        navigationIcons[i],
                        color: i == currentIndex ? Colors.blueGrey : Colors.black54,
                        size: i == currentIndex ? 30 : 26,
                      ),
                    ),
                  ),
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}
