import 'package:flutter/material.dart';
import 'package:tourify/features/airline_user/views/add_flight_schedule_view.dart';
import 'package:tourify/features/profile/views/profile_view.dart';

class AirlineMainLayoutView extends StatefulWidget {
  final int initialIndex;

  const AirlineMainLayoutView({super.key, this.initialIndex = 0});

  @override
  State<AirlineMainLayoutView> createState() => _AirlineMainLayoutViewState();
}

class _AirlineMainLayoutViewState extends State<AirlineMainLayoutView> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void changeTab(int index) => setState(() => currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          AddFlightScheduleView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0F766E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flight_takeoff_rounded), label: 'Schedules'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}