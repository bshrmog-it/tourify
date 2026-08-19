import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/const.dart';
import 'package:tourify/features/bookings/cubits/my_bookings_cubit.dart';
import 'package:tourify/features/bookings/cubits/my_bookings_state.dart';
import 'package:tourify/features/bookings/views/widgets/packages_tab.dart';
import 'package:tourify/features/bookings/views/widgets/standalone_bookings_list.dart';

class MyBookingsView extends StatelessWidget {
  const MyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyBookingsCubit()..load(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'My Bookings',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: [
                Tab(text: 'Packages'),
                Tab(text: 'Individual'),
              ],
            ),
          ),
          body: BlocBuilder<MyBookingsCubit, MyBookingsState>(
            builder: (context, state) {
              if (state is MyBookingsLoading || state is MyBookingsInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimary),
                );
              }
              if (state is MyBookingsError) {
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
                              context.read<MyBookingsCubit>().load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final grouped = (state as MyBookingsLoaded).grouped;
              return TabBarView(
                children: [
                  PackagesTab(groups: grouped.packageBookings),
                  StandaloneBookingsList(bookings: grouped.standaloneBookings),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
