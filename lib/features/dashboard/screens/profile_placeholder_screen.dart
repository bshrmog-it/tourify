import 'package:flutter/material.dart';

// مكان محجوز لشاشة البروفايل — رفيقك بيبنيها لحاله، هون بس placeholder
// منشان الـ bottom nav يشتغل كامل بدون كراش.
class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile screen — built by teammate'),
      ),
    );
  }
}
