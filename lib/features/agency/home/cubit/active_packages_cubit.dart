import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/active_package_model.dart';
import '../services/agency_package_service.dart';
import 'active_packages_state.dart';

class ActivePackagesCubit extends Cubit<ActivePackagesState> {
  final AgencyPackageService _service = AgencyPackageService();

  ActivePackagesCubit() : super(ActivePackagesInitial());

  Future<void> loadActivePackages() async {
    emit(ActivePackagesLoading());
    try {
      final packages = await _service.getActivePackages();
      emit(ActivePackagesLoaded(packages));
    } catch (e) {
      emit(ActivePackagesError(e.toString()));
    }
  }

  /// بترجع تستخدم بعد الرجوع من صفحة الحجوزات، لتحديث كارد الباكج بالقائمة
  void updatePackage(ActivePackageModel updated) {
    final current = state;
    if (current is! ActivePackagesLoaded) return;

    final newList = current.packages
        .map((p) => p.id == updated.id ? updated : p)
        .toList();

    emit(ActivePackagesLoaded(newList));
  }
}
