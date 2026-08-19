import '../models/active_package_model.dart';
import '../models/package_booking_model.dart';

abstract class PackageBookingsState {}

class PackageBookingsInitial extends PackageBookingsState {}

class PackageBookingsLoading extends PackageBookingsState {}

class PackageBookingsLoaded extends PackageBookingsState {
  final List<PackageBookingModel> bookings;
  final ActivePackageModel package;
  PackageBookingsLoaded({required this.bookings, required this.package});
}

class PackageBookingsError extends PackageBookingsState {
  final String message;
  PackageBookingsError(this.message);
}

/// حالة مؤقتة وقت ما نرسل approve/reject لحجز معين، لعرض تحميل صغير على كارده بس
class PackageBookingActionLoading extends PackageBookingsState {
  final List<PackageBookingModel> bookings;
  final ActivePackageModel package;
  final int bookingId;
  PackageBookingActionLoading({
    required this.bookings,
    required this.package,
    required this.bookingId,
  });
}
