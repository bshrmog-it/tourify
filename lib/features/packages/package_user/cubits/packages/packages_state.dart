import 'package:tourify/features/packages/package_user/models/package_model.dart';

abstract class PackagesState {}

class PackagesInitial extends PackagesState {}

class PackagesLoading extends PackagesState {}

class PackagesLoaded extends PackagesState {
  final List<PackageModel> packages;
  PackagesLoaded({required this.packages});
}

class PackagesError extends PackagesState {
  final String message;
  PackagesError({required this.message});
}
