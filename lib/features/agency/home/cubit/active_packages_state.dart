import '../models/active_package_model.dart';

abstract class ActivePackagesState {}

class ActivePackagesInitial extends ActivePackagesState {}

class ActivePackagesLoading extends ActivePackagesState {}

class ActivePackagesLoaded extends ActivePackagesState {
  final List<ActivePackageModel> packages;
  ActivePackagesLoaded(this.packages);
}

class ActivePackagesError extends ActivePackagesState {
  final String message;
  ActivePackagesError(this.message);
}
