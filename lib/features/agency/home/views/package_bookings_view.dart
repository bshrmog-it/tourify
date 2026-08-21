import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/core/const.dart';
import 'package:tourify/features/agency/home/cubit/package_bookings_cubit.dart';
import 'package:tourify/features/agency/home/cubit/package_bookings_state.dart';
import 'package:tourify/features/agency/home/models/active_package_model.dart';
import 'package:tourify/features/agency/home/models/package_booking_model.dart';
import 'package:tourify/features/agency/home/views/widgets/booking_requests_list.dart';
import 'package:tourify/features/agency/home/views/widgets/booking_stats_bar.dart';

const _kReject = Color(0xFFDC2626);

class PackageBookingsView extends StatelessWidget {
  final ActivePackageModel package;

  const PackageBookingsView({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PackageBookingsCubit(package)..loadBookings(),
      child: _PackageBookingsScaffold(initialPackage: package),
    );
  }
}

class _PackageBookingsScaffold extends StatelessWidget {
  final ActivePackageModel initialPackage;

  const _PackageBookingsScaffold({required this.initialPackage});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        Navigator.pop(
          context,
          context.read<PackageBookingsCubit>().currentPackage,
        );
      },

      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: AppBar(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,

          title: Text(
            initialPackage.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),

          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(
              context,
              context.read<PackageBookingsCubit>().currentPackage,
            ),
          ),
        ),

        body: BlocConsumer<PackageBookingsCubit, PackageBookingsState>(
          listener: (context, state) {
            if (state is PackageBookingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: _kReject,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },

          builder: (context, state) {
            if (state is PackageBookingsLoading ||
                state is PackageBookingsInitial) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            final package = _packageOf(state) ?? initialPackage;
            final bookings = _bookingsOf(state);

            final loadingBookingId = state is PackageBookingActionLoading
                ? state.bookingId
                : null;

            return Column(
              children: [
                BookingStatsBar(package: package),

                Expanded(
                  child: bookings == null
                      ? Center(
                          child: Text(
                            state is PackageBookingsError
                                ? state.message
                                : 'Something went wrong',
                            style: TextStyle(color: colors.onSurface),
                          ),
                        )
                      : BookingRequestsList(
                          bookings: bookings,
                          loadingBookingId: loadingBookingId,
                          onApprove: (id) =>
                              context.read<PackageBookingsCubit>().approve(id),
                          onReject: (id) =>
                              context.read<PackageBookingsCubit>().reject(id),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ActivePackageModel? _packageOf(PackageBookingsState state) {
    if (state is PackageBookingsLoaded) {
      return state.package;
    }

    if (state is PackageBookingActionLoading) {
      return state.package;
    }

    return null;
  }

  List<PackageBookingModel>? _bookingsOf(PackageBookingsState state) {
    if (state is PackageBookingsLoaded) {
      return state.bookings;
    }

    if (state is PackageBookingActionLoading) {
      return state.bookings;
    }

    return null;
  }
}
