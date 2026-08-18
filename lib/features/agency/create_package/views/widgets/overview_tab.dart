import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/agency/create_package/cubits/countries/countries_cubit.dart';
import 'package:tourify/features/agency/create_package/cubits/countries/countries_state.dart';
import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_cubit.dart';
import 'package:tourify/features/agency/create_package/models/city_model.dart';
import 'package:tourify/features/agency/create_package/models/country_model.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final cubit = context.read<PackageCreationCubit>();
    final state = cubit.state;

    final today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: state.startDate ?? today,
      firstDate: today,
      lastDate: DateTime(2050),
    );

    if (picked == null) {
      return;
    }

    final currentEnd = state.endDate;

    if (currentEnd != null && currentEnd.isBefore(picked)) {
      cubit.setTripDates(startDate: picked, endDate: picked);
    } else {
      cubit.setTripDates(startDate: picked, endDate: currentEnd ?? picked);
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final cubit = context.read<PackageCreationCubit>();
    final state = cubit.state;

    if (state.startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('حدد تاريخ البداية أولاً')));
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: state.endDate ?? state.startDate!,
      firstDate: state.startDate!,
      lastDate: DateTime(2050),
    );

    if (picked == null) {
      return;
    }

    cubit.setTripDates(startDate: state.startDate!, endDate: picked);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PackageCreationCubit>();
    final state = context.watch<PackageCreationCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // PACKAGE NAME
          // ============================================================
          const _Label('Package name'),

          TextFormField(
            initialValue: state.name,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter package name',
            ),
            onChanged: (value) {
              cubit.setBasicInfo(name: value);
            },
          ),

          const SizedBox(height: 20),

          // ============================================================
          // DEPARTURE COUNTRY
          // ============================================================
          const _Label('Departure country'),

          BlocBuilder<CountriesCubit, CountriesState>(
            builder: (context, countryState) {
              if (countryState is CountriesLoading) {
                return const LinearProgressIndicator();
              }

              if (countryState is CountriesError) {
                return Text(
                  countryState.message,
                  style: const TextStyle(color: Colors.red),
                );
              }

              final countries = countryState is CountriesLoaded
                  ? countryState.countries
                  : <CountryModel>[];

              return DropdownButtonFormField<CountryModel>(
                value: state.originCountry,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose departure country',
                ),
                items: countries.map((country) {
                  return DropdownMenuItem<CountryModel>(
                    value: country,
                    child: Text(country.name),
                  );
                }).toList(),
                onChanged: (country) {
                  if (country != null) {
                    cubit.selectOriginCountry(country);
                  }
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // ============================================================
          // DEPARTURE CITY
          // ============================================================
          const _Label('Departure city'),

          DropdownButtonFormField<CityModel>(
            value: state.originCity,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Choose departure city',
            ),
            items:
                state.originCountry?.cities
                    .map(
                      (city) => DropdownMenuItem<CityModel>(
                        value: city,
                        child: Text(city.name),
                      ),
                    )
                    .toList() ??
                <DropdownMenuItem<CityModel>>[],
            onChanged: state.originCountry == null
                ? null
                : (CityModel? city) {
                    if (city != null) {
                      cubit.selectOriginCity(city);
                    }
                  },
          ),

          const SizedBox(height: 20),

          // ============================================================
          // DESTINATION COUNTRY
          // ============================================================
          const _Label('Destination country'),

          BlocBuilder<CountriesCubit, CountriesState>(
            builder: (context, countryState) {
              if (countryState is CountriesLoading) {
                return const LinearProgressIndicator();
              }

              if (countryState is CountriesError) {
                return Text(
                  countryState.message,
                  style: const TextStyle(color: Colors.red),
                );
              }

              final countries = countryState is CountriesLoaded
                  ? countryState.countries
                  : <CountryModel>[];

              return DropdownButtonFormField<CountryModel>(
                value: state.country,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose destination country',
                ),
                items: countries.map((country) {
                  return DropdownMenuItem<CountryModel>(
                    value: country,
                    child: Text(country.name),
                  );
                }).toList(),
                onChanged: (country) {
                  if (country != null) {
                    cubit.selectCountry(country);
                  }
                },
              );
            },
          ),

          const SizedBox(height: 20),

          // ============================================================
          // DESCRIPTION
          // ============================================================
          const _Label('Description'),

          TextFormField(
            initialValue: state.description,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Package description',
            ),
            onChanged: (value) {
              cubit.setBasicInfo(description: value);
            },
          ),

          const SizedBox(height: 20),

          // ============================================================
          // QUANTITY
          // ============================================================
          const _Label('Quantity (seats)'),

          TextFormField(
            initialValue: state.quantity.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (value) {
              final quantity = int.tryParse(value);

              if (quantity != null && quantity > 0) {
                cubit.setBasicInfo(quantity: quantity);
              }
            },
          ),

          const SizedBox(height: 24),

          // ============================================================
          // TRIP DATES
          // ============================================================
          const _Label('Trip dates'),

          Row(
            children: [
              Expanded(
                child: _DateCard(
                  title: 'Start Date',
                  value: _formatDate(state.startDate),
                  icon: Icons.calendar_today_outlined,
                  onTap: () {
                    _pickStartDate(context);
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _DateCard(
                  title: 'End Date',
                  value: _formatDate(state.endDate),
                  icon: Icons.event_outlined,
                  onTap: () {
                    _pickEndDate(context);
                  },
                ),
              ),
            ],
          ),

          // ============================================================
          // DAYS COUNT
          // ============================================================
          const SizedBox(height: 20),

          // ============================================================
          // FLIGHT OPTION
          // ============================================================
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SwitchListTile(
              title: const Text(
                'Include flights',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                state.withFlight
                    ? 'Departure and return flights required'
                    : 'Package without flights',
              ),
              value: state.withFlight,
              onChanged: (value) {
                cubit.setWithFlight(value);
              },
            ),
          ),

          const SizedBox(height: 20),

          // ============================================================
          // SUMMARY
          // ============================================================
          if (state.originCity != null &&
              state.country != null &&
              state.tripDays > 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Text('From: ${state.originCity!.name}'),

                  const SizedBox(height: 6),

                  Text('To: ${state.country!.name}'),

                  const SizedBox(height: 6),

                  Text('Duration: ${state.tripDays} days'),

                  const SizedBox(height: 6),

                  Text(
                    state.withFlight
                        ? 'Flights: Included'
                        : 'Flights: Not included',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.indigo, size: 20),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
