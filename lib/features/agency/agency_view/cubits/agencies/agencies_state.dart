import 'package:tourify/features/agency/agency_view/models/agency_model.dart';

abstract class AgenciesState {}

class AgenciesInitial extends AgenciesState {}

class AgenciesLoading extends AgenciesState {}

class AgenciesLoaded extends AgenciesState {
  final List<AgencyModel> agencies;
  AgenciesLoaded({required this.agencies});
}

class AgenciesError extends AgenciesState {
  final String message;
  AgenciesError({required this.message});
}
