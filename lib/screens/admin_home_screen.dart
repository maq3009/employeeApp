import 'package:flutter/material.dart';
import 'package:employee_attendance/screens/admin_calendar_screen.dart';
import 'package:employee_attendance/screens/profile_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee_attendance/models/user_model.dart';  // Import your UserModel
import 'package:employee_attendance/services/user_service.dart'; // Import the UserService

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int currentIndex = 0; // Set initial index to 0 for Admin Calendar

  final List<Widget> screens = [
    const AdminCalendarScreen(employeeId: '', arguments: {}),
    const ProfileScreen(),
  ];

  final List<IconData> navigationIcons = [
    FontAwesomeIcons.solidCalendarDays,
    FontAwesomeIcons.solidUser,
  ];

  final List<String> titles = [
    "Admin Calendar",
    "Admin Profile",
  ];

  List<UserModel> employees = []; // List to store employee data

  @override
  void initState() {
    super.initState();
    _getEmployees();  // Fetch employee data when the screen is initialized
  }

  // Fetch employee data
  Future<void> _getEmployees() async {
    final List<UserModel> fetchedEmployees = await UserService().getEmployees(); // Using the UserService
    setState(() {
      employees = fetchedEmployees;
    });
  }

  // Method to navigate to AdminCalendarScreen when an employee is selected
void _onEmployeeSelected(UserModel employee) {
  print('Selected employee ID (UUID): ${employee.id}'); // Debugging
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AdminCalendarScreen(
        employeeId: employee.id, // Pass the UUID instead of employeeId
        arguments: {
          'employeeName': employee.name,
        },
      ),
    ),
  );
}



  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex]),
        backgroundColor: Colors.blueGrey,
      ),
      body: currentIndex == 0
          ? Column(
              children: [
                // List of employee buttons
                Expanded(
                  child: ListView.builder(
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return ListTile(
                        title: Text(employee.name),
                        onTap: () => _onEmployeeSelected(employee),
                      );
                    },
                  ),
                ),
              ],
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
                  onTap: () => onTabTapped(i),
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
    );
  }
}
