import 'package:employee_attendance/screens/admin_calendar_screen.dart';
import 'package:employee_attendance/screens/admin_splash_screen.dart';
import 'package:employee_attendance/screens/splash_screen.dart';
import 'package:employee_attendance/services/attendance_service.dart';
import 'package:employee_attendance/services/auth_services.dart';
import 'package:employee_attendance/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load();
  // Initialize Supabase
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseKey = dotenv.env['SUPABASE_KEY'] ?? '';
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => DbService()),
        ChangeNotifierProvider(create: (context) => AttendanceService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Employee Attendance",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Define home screen
        home: const SplashScreen(),
        // Define route generation logic
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/adminCalendar':
              final args = settings.arguments as Map<String, dynamic>?;

              if (args == null || !args.containsKey('employeeId')) {
                // If arguments are missing, navigate to a fallback screen or show an error
                return MaterialPageRoute(
                  builder: (context) => const AdminSplashScreen(),
                );
              }

              return MaterialPageRoute(
                builder: (context) => AdminCalendarScreen(
                  employeeId: args['employeeId'],
                  arguments: args,
                ),
              );

            default:
              // Fallback route
              return MaterialPageRoute(
                builder: (context) => const AdminSplashScreen(),
              );
          }
        },
      ),
    );
  }
}
