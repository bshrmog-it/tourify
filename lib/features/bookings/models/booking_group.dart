import 'booking_model.dart';

/// حجز باكج كامل: الصف الأب + كل العناصر التابعة له
class PackageBookingGroup {
  bool get isCompleted {
    if (status != 'confirmed') return false;
    final date = DateTime.tryParse(bookingDate);
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  final BookingModel parent;
  final List<BookingModel> items;

  PackageBookingGroup({required this.parent, required this.items});

  int get packageId => parent.bookableId;
  String get status => parent.status;
  String get bookingDate => parent.bookingDate;

  int get hotelRoomsCount =>
      items.where((i) => i.bookableType == BookableType.hotelRoom).length;
  int get flightsCount =>
      items.where((i) => i.bookableType == BookableType.flightSchedule).length;
  int get restaurantsCount =>
      items.where((i) => i.bookableType == BookableType.restaurant).length;
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
