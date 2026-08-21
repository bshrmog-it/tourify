import 'package:tourify/features/dashboard/services/get_dashboard.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  final String? selectedCountry;
  DashboardLoaded({required this.data, this.selectedCountry});
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError({required this.message});
}
