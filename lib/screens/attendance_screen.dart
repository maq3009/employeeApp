import 'package:employee_attendance/models/user_model.dart';
import 'package:employee_attendance/services/attendance_service.dart';
import 'package:employee_attendance/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final GlobalKey<SlideActionState> sliderKey = GlobalKey<SlideActionState>();
  final GlobalKey<SlideActionState> breakSliderKey = GlobalKey<SlideActionState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceService>(context, listen: false).getTodayAttendance();
    });
  }

  String formatBreakTime(String? time) {
    if (time == null || time == '--/--') return '--/--';
    try {
      final dt = DateTime.parse(time).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceService = Provider.of<AttendanceService>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header and user info
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: const Text(
                "Welcome",
                style: TextStyle(color: Colors.black54, fontSize: 30),
              ),
            ),
            Consumer<DbService>(
              builder: (context, dbService, child) {
                return FutureBuilder<UserModel>(
                  future: dbService.getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      UserModel user = snapshot.data!;
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.name.isNotEmpty ? user.name : "#${user.employeeId}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                );
              },
            ),

            // Today's Status
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: const Text(
                "Today's Status",
                style: TextStyle(fontSize: 25),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30, bottom: 32),
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2)),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Check In
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Check In",
                          style: TextStyle(fontSize: 20, color: Colors.black54),
                        ),
                        const Divider(),
                        Text(
                          attendanceService.attendanceModel?.checkIn ?? '--/--',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  // Check Out
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Check Out",
                          style: TextStyle(fontSize: 20, color: Colors.black54),
                        ),
                        const Divider(),
                        Text(
                          attendanceService.attendanceModel?.checkOut ?? '--/--',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Break In/Out Times
            if (attendanceService.attendanceModel?.checkIn != null)
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2)),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Break In
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Break In",
                            style: TextStyle(fontSize: 20, color: Colors.black54),
                          ),
                          const Divider(),
                          Text(
                            formatBreakTime(attendanceService.attendanceModel?.breakIn),
                            style: const TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                    // Break Out
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Break Out",
                            style: TextStyle(fontSize: 20, color: Colors.black54),
                          ),
                          const Divider(),
                          Text(
                            formatBreakTime(attendanceService.attendanceModel?.breakOut),
                            style: const TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Slide to Check In/Out
            Container(
              margin: const EdgeInsets.only(top: 25),
              child: SlideAction(
                text: attendanceService.attendanceModel?.checkIn == null
                    ? "Slide to Check In"
                    : "Slide to Check Out",
                textStyle: const TextStyle(color: Colors.black54, fontSize: 18),
                outerColor: Colors.white,
                innerColor: Colors.blueGrey,
                key: sliderKey,
                onSubmit: () async {
                  await attendanceService.markAttendance(context);
                  setState(() {});
                  sliderKey.currentState?.reset();
                },
              ),
            ),

            // Slide to Start/End Break
            if (attendanceService.attendanceModel?.checkIn != null &&
                attendanceService.attendanceModel?.checkOut == null)
              Container(
                margin: const EdgeInsets.only(top: 25),
                child: SlideAction(
                  text: attendanceService.isOnBreak
                      ? "Slide to End Break"
                      : "Slide to Start Break",
                  textStyle: const TextStyle(color: Colors.black54, fontSize: 18),
                  outerColor: Colors.white,
                  innerColor: attendanceService.isOnBreak ? Colors.redAccent : Colors.greenAccent,
                  key: breakSliderKey,
                  onSubmit: () async {
                    if (attendanceService.isOnBreak) {
                      await attendanceService.endBreak(context);
                    } else {
                      await attendanceService.startBreak(context);
                    }
                    setState(() {});
                    breakSliderKey.currentState?.reset();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
