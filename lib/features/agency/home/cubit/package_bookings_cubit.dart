import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/active_package_model.dart';
import '../services/agency_package_service.dart';
import 'package_bookings_state.dart';

class PackageBookingsCubit extends Cubit<PackageBookingsState> {
  final AgencyPackageService _service = AgencyPackageService();
  ActivePackageModel _package;

  PackageBookingsCubit(ActivePackageModel initialPackage)
    : _package = initialPackage,
      super(PackageBookingsInitial());

  ActivePackageModel get currentPackage => _package;

  Future<void> loadBookings() async {
    emit(PackageBookingsLoading());
    try {
      final bookings = await _service.getPendingBookings(_package.id);
      emit(PackageBookingsLoaded(bookings: bookings, package: _package));
    } catch (e) {
      emit(PackageBookingsError(e.toString()));
    }
  }

  Future<void> approve(int bookingId) async {
    final current = state;

    if (current is! PackageBookingsLoaded) return;

    emit(
      PackageBookingActionLoading(
        bookings: current.bookings,
        package: current.package,
        bookingId: bookingId,
      ),
    );

    try {
      await _service.approveBooking(_package.id, bookingId);

      final updatedBookings = current.bookings
          .where((b) => b.id != bookingId)
          .toList();

      final newConfirmedCount = _package.confirmedCount + 1;

      final newAvailableCount = (_package.quantity - newConfirmedCount).clamp(
        0,
        _package.quantity,
      );

      _package = _package.copyWith(
        pendingCount: (_package.pendingCount - 1).clamp(0, 999999),
        confirmedCount: newConfirmedCount,
        availableCount: newAvailableCount,

        // Rejected does NOT change.
      );

      emit(PackageBookingsLoaded(bookings: updatedBookings, package: _package));
    } catch (e) {
      emit(PackageBookingsError(e.toString()));
    }
  }

  Future<void> reject(int bookingId) async {
    final current = state;

    if (current is! PackageBookingsLoaded) return;

    emit(
      PackageBookingActionLoading(
        bookings: current.bookings,
        package: current.package,
        bookingId: bookingId,
      ),
    );

    try {
      await _service.rejectBooking(_package.id, bookingId);

      final updatedBookings = current.bookings
          .where((b) => b.id != bookingId)
          .toList();

      _package = _package.copyWith(
        pendingCount: (_package.pendingCount - 1).clamp(0, 999999),
        rejectedCount: _package.rejectedCount + 1,

        // IMPORTANT:
        // Available does NOT change when rejecting.
      );

      emit(PackageBookingsLoaded(bookings: updatedBookings, package: _package));
    } catch (e) {
      emit(PackageBookingsError(e.toString()));
    }
  }
}
