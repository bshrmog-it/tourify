import 'package:flutter/material.dart';
import 'package:tourify/features/agency/home/views/active_packages_view.dart';
import 'package:tourify/features/profile/views/profile_view.dart';

class AgencyMainLayoutView extends StatefulWidget {
  final int initialIndex;

  const AgencyMainLayoutView({super.key, this.initialIndex = 0});

  @override
  State<AgencyMainLayoutView> createState() => _AgencyMainLayoutViewState();
}

class _AgencyMainLayoutViewState extends State<AgencyMainLayoutView> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void changeTab(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [ActivePackagesView(), ProfileView()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0F766E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
