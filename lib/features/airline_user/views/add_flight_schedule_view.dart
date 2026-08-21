import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/airline_user/cubits/create_schedule_cubit.dart';
import 'package:tourify/features/airline_user/cubits/create_schedule_state.dart';
import 'package:tourify/features/airline_user/cubits/flights_dropdown_cubit.dart';
import 'package:tourify/features/airline_user/cubits/flights_dropdown_state.dart';
import 'package:tourify/features/airline_user/models/dropdown_flight_model.dart';
import 'package:tourify/features/airline_user/views/widgets/days_of_week_selector.dart';

class AddFlightScheduleView extends StatelessWidget {
  const AddFlightScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FlightsDropdownCubit()..loadFlights()),
        BlocProvider(create: (_) => CreateScheduleCubit()),
      ],
      child: const _AddFlightScheduleBody(),
    );
  }
}

class _AddFlightScheduleBody extends StatefulWidget {
  const _AddFlightScheduleBody();

  @override
  State<_AddFlightScheduleBody> createState() => _AddFlightScheduleBodyState();
}

class _AddFlightScheduleBodyState extends State<_AddFlightScheduleBody> {
  DropdownFlightModel? _selectedFlight;
  TimeOfDay? _departureTime;
  TimeOfDay? _arrivalTime;
  DateTime? _startDate;
  final _weeksController = TextEditingController(text: '1');
  final Set<int> _selectedDays = {};

  @override
  void dispose() {
    _weeksController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime({required bool isDeparture}) async {
    final theme = Theme.of(context);

    final picked = await showTimePicker(
      context: context,
      initialTime:
          (isDeparture ? _departureTime : _arrivalTime) ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isDeparture) {
        _departureTime = picked;
      } else {
        _arrivalTime = picked;
      }
    });
  }

  Future<void> _pickStartDate() async {
    final theme = Theme.of(context);

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }

  void _submit() {
    if (_selectedFlight == null) {
      return _showMessage('Please select a flight', isError: true);
    }

    if (_departureTime == null) {
      return _showMessage('Please pick a departure time', isError: true);
    }

    if (_arrivalTime == null) {
      return _showMessage('Please pick an arrival time', isError: true);
    }

    if (_startDate == null) {
      return _showMessage('Please pick a start date', isError: true);
    }

    if (_selectedDays.isEmpty) {
      return _showMessage(
        'Please select at least one day of the week',
        isError: true,
      );
    }

    final weeks = int.tryParse(_weeksController.text);

    if (weeks == null || weeks <= 0) {
      return _showMessage(
        'Please enter a valid number of weeks',
        isError: true,
      );
    }

    context.read<CreateScheduleCubit>().createSchedule(
      flightId: _selectedFlight!.id,
      departureTime: _formatTime(_departureTime!),
      arrivalTime: _formatTime(_arrivalTime!),
      startDate: _formatDate(_startDate!),
      weeks: weeks,
      daysOfWeek: _selectedDays.toList()..sort(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        title: const Text(
          'Add Flight Schedule',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: BlocListener<CreateScheduleCubit, CreateScheduleState>(
        listener: (context, state) {
          if (state is CreateScheduleSuccess) {
            _showMessage('Schedule added successfully');

            setState(() {
              _selectedFlight = null;
              _departureTime = null;
              _arrivalTime = null;
              _startDate = null;
              _weeksController.text = '1';
              _selectedDays.clear();
            });
          }

          if (state is CreateScheduleError) {
            _showMessage(state.message, isError: true);
          }
        },

        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Flight route',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            BlocBuilder<FlightsDropdownCubit, FlightsDropdownState>(
              builder: (context, state) {
                if (state is FlightsDropdownLoading ||
                    state is FlightsDropdownInitial) {
                  return const LinearProgressIndicator();
                }

                if (state is FlightsDropdownError) {
                  return Text(
                    state.message,
                    style: TextStyle(color: colors.error),
                  );
                }

                final flights = state is FlightsDropdownLoaded
                    ? state.flights
                    : <DropdownFlightModel>[];

                return DropdownButtonFormField<DropdownFlightModel>(
                  value: _selectedFlight,
                  isExpanded: true,

                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: colors.surface,
                    hintText: 'Choose a route',
                    hintStyle: TextStyle(color: colors.onSurfaceVariant),
                  ),

                  dropdownColor: colors.surface,

                  style: TextStyle(color: colors.onSurface),

                  items: flights
                      .map(
                        (f) => DropdownMenuItem(
                          value: f,
                          child: Text(
                            f.text,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.onSurface),
                          ),
                        ),
                      )
                      .toList(),

                  onChanged: (f) {
                    setState(() => _selectedFlight = f);
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            Text(
              'Departure & arrival time',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _TimeCard(
                    label: 'Departure',
                    value: _departureTime == null
                        ? 'Select'
                        : _formatTime(_departureTime!),
                    onTap: () => _pickTime(isDeparture: true),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _TimeCard(
                    label: 'Arrival',
                    value: _arrivalTime == null
                        ? 'Select'
                        : _formatTime(_arrivalTime!),
                    onTap: () => _pickTime(isDeparture: false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'Start date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: _pickStartDate,
              borderRadius: BorderRadius.circular(12),

              child: Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outline),
                ),

                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: colors.primary,
                      size: 20,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      _startDate == null
                          ? 'Select start date'
                          : _formatDate(_startDate!),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Number of weeks',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _weeksController,
              keyboardType: TextInputType.number,

              style: TextStyle(color: colors.onSurface),

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
                filled: true,
                fillColor: colors.surface,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Repeats on',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            DaysOfWeekSelector(
              selectedDays: _selectedDays,
              onToggle: (day) => setState(() {
                if (_selectedDays.contains(day)) {
                  _selectedDays.remove(day);
                } else {
                  _selectedDays.add(day);
                }
              }),
            ),

            const SizedBox(height: 30),

            BlocBuilder<CreateScheduleCubit, CreateScheduleState>(
              builder: (context, state) {
                final loading = state is CreateScheduleLoading;

                return SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: loading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Text(
                            'Create Schedule',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),

      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: colors.primary,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
