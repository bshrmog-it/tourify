import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/airlines/cubits/flight_booking/flight_booking_cubit.dart';
import 'package:tourify/features/airlines/cubits/flight_booking/flight_booking_state.dart';
import 'package:tourify/features/airlines/cubits/flight_schedules/flight_schedules_cubit.dart';
import 'package:tourify/features/airlines/cubits/flight_schedules/flight_schedules_state.dart';
import 'package:tourify/features/airlines/models/flight_model.dart';
import 'package:tourify/features/airlines/models/flight_schedule_model.dart';
import 'package:tourify/features/airlines/screens/flight_booking_success_screen.dart';
import 'package:tourify/shared/widgets/wallet_badge.dart';

class FlightSchedulesScreen extends StatelessWidget {
  final FlightModel flight;
  final String airlineName;

  const FlightSchedulesScreen({
    super.key,
    required this.flight,
    required this.airlineName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FlightSchedulesCubit()..getSchedules(flight.id),
      child: BlocProvider(
        create: (_) => FlightBookingCubit(),
        child: _FlightSchedulesView(
          flight: flight,
          airlineName: airlineName,
        ),
      ),
    );
  }
}

class _FlightSchedulesView extends StatelessWidget {
  final FlightModel flight;
  final String airlineName;

  const _FlightSchedulesView({
    required this.flight,
    required this.airlineName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return BlocListener<FlightBookingCubit, FlightBookingState>(
      listener: (context, state) {
        if (state is FlightBookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state is FlightBookingSuccess) {
          final schedule = _lastSelectedSchedule;
          if (schedule == null) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => FlightBookingSuccessScreen(
                booking: state.booking,
                airlineName: airlineName,
                fromCity: flight.fromCity.name,
                toCity: flight.toCity.name,
                departureTime: _time(schedule.departureTime),
                arrivalTime: _time(schedule.arrivalTime),
                scheduleDate: _dateLabel(schedule.date),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flight schedules'),
          elevation: 0,
          actions: const [
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: WalletBadge(),
            ),
            SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<FlightSchedulesCubit, FlightSchedulesState>(
          builder: (context, state) {
            if (state is FlightSchedulesLoading ||
                state is FlightSchedulesInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is FlightSchedulesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final schedules = (state as FlightSchedulesLoaded).schedules;

            return RefreshIndicator(
              onRefresh: () => context
                  .read<FlightSchedulesCubit>()
                  .getSchedules(flight.id),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            airlineName,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  flight.fromCity.name,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.flight_rounded,
                                color: scheme.primary,
                              ),
                              Expanded(
                                child: Text(
                                  flight.toCity.name,
                                  textAlign: TextAlign.right,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Starting from \$${flight.price.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (schedules.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No schedules available for this flight.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                      sliver: SliverList.separated(
                        itemCount: schedules.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, index) => _ScheduleCard(
                          schedule: schedules[index],
                          airlineName: airlineName,
                          flight: flight,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static FlightScheduleModel? _lastSelectedSchedule;

  String _dateLabel(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _time(String value) {
    if (value.length >= 5) return value.substring(0, 5);
    return value;
  }
}

class _ScheduleCard extends StatelessWidget {
  final FlightScheduleModel schedule;
  final String airlineName;
  final FlightModel flight;

  const _ScheduleCard({
    required this.schedule,
    required this.airlineName,
    required this.flight,
  });

  String _dateLabel(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _time(String value) {
    if (value.length >= 5) return value.substring(0, 5);
    return value;
  }

  Future<void> _showBookingConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final scheme = theme.colorScheme;

        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Confirm booking',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please review your flight details before confirming.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // Airline
                _ConfirmationRow(
                  icon: Icons.business_rounded,
                  label: 'Airline',
                  value: airlineName,
                ),

                const SizedBox(height: 14),

                // Route
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withOpacity(.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _RoutePoint(
                          city: flight.fromCity.name,
                          label: 'Departure',
                          time: _time(schedule.departureTime),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: scheme.primary,
                        ),
                      ),
                      Expanded(
                        child: _RoutePoint(
                          city: flight.toCity.name,
                          label: 'Arrival',
                          time: _time(schedule.arrivalTime),
                          right: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                _ConfirmationRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: _dateLabel(schedule.date),
                ),

                const SizedBox(height: 14),

                _ConfirmationRow(
                  icon: Icons.event_seat_rounded,
                  label: 'Available seats',
                  value: '${schedule.seats}',
                ),

                const SizedBox(height: 18),

                // Price
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.primary.withOpacity(.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Total price',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '\$${flight.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The booking will be confirmed after you continue.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Confirm Booking'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    // The booking endpoint receives the FlightSchedule ID.
    _FlightSchedulesView._lastSelectedSchedule = schedule;

    context.read<FlightBookingCubit>().book(schedule.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _dateLabel(schedule.date),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _SeatsBadge(seats: schedule.seats),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimeBlock(
                  label: 'Departure',
                  time: _time(schedule.departureTime),
                  icon: Icons.flight_takeoff_rounded,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: _TimeBlock(
                  label: 'Arrival',
                  time: _time(schedule.arrivalTime),
                  icon: Icons.flight_land_rounded,
                  right: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: BlocBuilder<FlightBookingCubit, FlightBookingState>(
              builder: (context, state) {
                final loading = state is FlightBookingLoading;

                return FilledButton(
                  onPressed: loading
                      ? null
                      : () => _showBookingConfirmation(context),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Book Now'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 19,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final String city;
  final String label;
  final String time;
  final bool right;

  const _RoutePoint({
    required this.city,
    required this.label,
    required this.time,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment:
          right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          time,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: right ? TextAlign.right : TextAlign.left,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final bool right;

  const _TimeBlock({
    required this.label,
    required this.time,
    required this.icon,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
          right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              right ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!right) ...[
              Icon(
                icon,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            if (right) ...[
              const SizedBox(width: 5),
              Icon(
                icon,
                size: 16,
                color: scheme.primary,
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          time,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _SeatsBadge extends StatelessWidget {
  final int seats;

  const _SeatsBadge({
    required this.seats,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(.09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_seat_rounded,
            size: 15,
            color: scheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            '$seats seats',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}