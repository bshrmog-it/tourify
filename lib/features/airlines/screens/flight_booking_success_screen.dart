import 'package:flutter/material.dart';
import 'package:tourify/features/airlines/models/flight_booking_model.dart';
import 'package:tourify/shared/widgets/wallet_badge.dart';

class FlightBookingSuccessScreen extends StatelessWidget {
  final FlightBookingModel booking;
  final String airlineName;
  final String fromCity;
  final String toCity;
  final String departureTime;
  final String arrivalTime;
  final String scheduleDate;

  const FlightBookingSuccessScreen({
    super.key,
    required this.booking,
    required this.airlineName,
    required this.fromCity,
    required this.toCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.scheduleDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Booking Created'),
        centerTitle: true,
        elevation: 0,
        actions: const [
          Padding(padding: EdgeInsets.only(top: 8), child: WalletBadge()),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: scheme.primary,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your booking was created',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 7),
              Text(
                'Your booking request was created successfully. Its current status is shown below.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airlineName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _CityTime(
                            city: fromCity,
                            time: departureTime,
                            label: 'Departure',
                          ),
                        ),
                        Icon(Icons.flight_rounded, color: scheme.primary),
                        Expanded(
                          child: _CityTime(
                            city: toCity,
                            time: arrivalTime,
                            label: 'Arrival',
                            right: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Divider(color: scheme.outlineVariant),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Booking ID', value: '#${booking.id}'),
                    _InfoRow(label: 'Booking date', value: booking.bookingDate),
                    _InfoRow(label: 'Status', value: booking.status),
                    _InfoRow(label: 'Schedule date', value: scheduleDate),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityTime extends StatelessWidget {
  final String city;
  final String time;
  final String label;
  final bool right;

  const _CityTime({
    required this.city,
    required this.time,
    required this.label,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: right ? TextAlign.right : TextAlign.left,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
