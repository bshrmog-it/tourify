import 'package:flutter/material.dart';
import 'package:tourify/core/const.dart';
import 'package:tourify/features/profile/model/profile_model.dart';

class AvatarHeader extends StatelessWidget {
  final ProfileModel profile;

  const AvatarHeader({super.key, required this.profile});

  String _initials() {
    final f = profile.firstName.isNotEmpty ? profile.firstName[0] : '';
    final l = profile.lastName.isNotEmpty ? profile.lastName[0] : '';
    final initials = (f + l).toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: kPrimary.withOpacity(0.12),
          backgroundImage:
              profile.profileImage != null && profile.profileImage!.isNotEmpty
              ? NetworkImage(profile.profileImage!)
              : null,
          child: profile.profileImage == null || profile.profileImage!.isEmpty
              ? Text(
                  _initials(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          profile.fullName.isEmpty ? profile.username : profile.fullName,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          '@${profile.username}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }
}
