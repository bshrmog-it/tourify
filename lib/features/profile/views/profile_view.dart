import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/const.dart';
import 'package:tourify/features/profile/cubit/profile_cubit.dart';
import 'package:tourify/features/profile/cubit/profile_state.dart';
import 'package:tourify/features/profile/views/widgets/avatar_header.dart';
import 'package:tourify/features/profile/views/widgets/credit_card.dart';
import 'package:tourify/features/profile/views/widgets/info_section.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'My Profile',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimary),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ProfileCubit>().loadProfile(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = (state as ProfileLoaded).profile;

            return RefreshIndicator(
              color: kPrimary,
              onRefresh: () => context.read<ProfileCubit>().loadProfile(),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AvatarHeader(profile: profile),
                  const SizedBox(height: 20),
                  CreditCard(credit: profile.credit),
                  const SizedBox(height: 20),
                  InfoSection(profile: profile),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
