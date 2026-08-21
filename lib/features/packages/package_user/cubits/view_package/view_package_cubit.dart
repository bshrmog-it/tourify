import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/packages/package_user/cubits/view_package/view_package_state.dart';
import 'package:tourify/features/packages/package_user/services/get_package_details.dart';
import 'package:tourify/features/packages/package_user/services/package_actions_service.dart';

class ViewPackageCubit extends Cubit<ViewPackageState> {
  ViewPackageCubit() : super(ViewPackageLoading());
  final GetPackageDetails _detailsService = GetPackageDetails();
  final PackageActionsService _actionsService = PackageActionsService();

  Future<void> load(int packageId) async {
    emit(ViewPackageLoading());
    try {
      final package = await _detailsService.getPackageDetails(packageId);
      emit(ViewPackageLoaded(package: package));
    } catch (e) {
      emit(ViewPackageError(message: e.toString()));
    }
  }

  Future<void> book(int packageId) async {
    await _actionsService.bookPackage(packageId);
  }
}
