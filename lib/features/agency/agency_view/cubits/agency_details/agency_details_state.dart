import 'package:tourify/features/agency/agency_view/models/agency_model.dart';

abstract class AgencyDetailsState {}

class AgencyDetailsInitial extends AgencyDetailsState {}

class AgencyDetailsLoading extends AgencyDetailsState {}

class AgencyDetailsLoaded extends AgencyDetailsState {
  final AgencyModel agency;
  AgencyDetailsLoaded({required this.agency});
}

class AgencyDetailsError extends AgencyDetailsState {
  final String message;
  AgencyDetailsError({required this.message});
}
