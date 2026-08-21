import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/packages/package_user/cubits/packages/packages_state.dart';
import 'package:tourify/features/packages/package_user/services/get_all_packages.dart';

class PackagesCubit extends Cubit<PackagesState> {
  PackagesCubit() : super(PackagesInitial());
  final GetAllPackages _service = GetAllPackages();

  Future<void> getPackages() async {
    emit(PackagesLoading());
    try {
      final packages = await _service.getAllPackages();
      emit(PackagesLoaded(packages: packages));
    } catch (e) {
      emit(PackagesError(message: e.toString()));
    }
  }
}
