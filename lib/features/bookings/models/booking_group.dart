import 'booking_model.dart';

class PackageBookingGroup {
  final BookingModel parent;
  final List<BookingModel> items;

  PackageBookingGroup({required this.parent, required this.items});

  int get packageId => parent.bookableId;
  String get status => parent.status;
  String get bookingDate => parent.bookingDate;

  String get displayName {
    for (final item in items) {
      if (item.packageName != null && item.packageName!.isNotEmpty) {
        return item.packageName!;
      }
    }
    return 'Package #$packageId';
  }

  int get hotelRoomsCount =>
      items.where((i) => i.bookableType == BookableType.hotelRoom).length;
  int get flightsCount =>
      items.where((i) => i.bookableType == BookableType.flightSchedule).length;
  int get restaurantsCount =>
      items.where((i) => i.bookableType == BookableType.restaurant).length;

  bool get isCompleted {
    if (status != 'confirmed') return false;
    final date = DateTime.tryParse(bookingDate);
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }
}

class StandaloneBooking {
  final BookingModel booking;
  StandaloneBooking(this.booking);
}

class GroupedBookings {
  final List<PackageBookingGroup> packageBookings;
  final List<StandaloneBooking> standaloneBookings;

  GroupedBookings({
    required this.packageBookings,
    required this.standaloneBookings,
  });

  factory GroupedBookings.fromRaw(List<BookingModel> all) {
    // 1) الصفوف الأب (package bookings)
    final parents = all
        .where((b) => b.bookableType == BookableType.package)
        .toList();

    final packageBookings = parents.map((parent) {
      final items = all.where((b) => b.packageBookingId == parent.id).toList();
      return PackageBookingGroup(parent: parent, items: items);
    }).toList();

    // 2) أي صف مش تابع لباكج ومش هو نفسه صف باكج ⇐ حجز فردي
    final standalone = all
        .where(
          (b) =>
              b.bookableType != BookableType.package &&
              b.packageBookingId == null,
        )
        .map((b) => StandaloneBooking(b))
        .toList();

    return GroupedBookings(
      packageBookings: packageBookings,
      standaloneBookings: standalone,
    );
  }
}
