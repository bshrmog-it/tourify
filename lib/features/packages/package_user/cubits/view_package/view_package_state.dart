import 'package:tourify/features/packages/package_user/models/package_model.dart';

abstract class ViewPackageState {}

class ViewPackageLoading extends ViewPackageState {}

class ViewPackageLoaded extends ViewPackageState {
  final PackageModel package;
  ViewPackageLoaded({required this.package});
}

class ViewPackageError extends ViewPackageState {
  final String message;
  ViewPackageError({required this.message});
}
