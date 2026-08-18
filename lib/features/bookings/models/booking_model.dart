enum BookableType {
  package,
  hotelRoom,
  flightSchedule,
  restaurant,
  place,
  unknown,
}

BookableType _parseBookableType(String raw) {
  switch (raw) {
    case 'App\\Models\\Package':
      return BookableType.package;
    case 'App\\Models\\HotelRoom':
      return BookableType.hotelRoom;
    case 'App\\Models\\FlightSchedule':
      return BookableType.flightSchedule;
    case 'App\\Models\\Restaurant':
      return BookableType.restaurant;
    case 'App\\Models\\Place':
      return BookableType.place;
    default:
      return BookableType.unknown;
  }
}

class BookingModel {
  final int id;
  final BookableType bookableType;
  final int bookableId;
  final String bookingDate;
  final String status; // pending, confirmed, rejected
  final int? packageBookingId;
  final int? packageId;
  final String createdAt;

  BookingModel({
    required this.id,
    required this.bookableType,
    required this.bookableId,
    required this.bookingDate,
    required this.status,
    required this.packageBookingId,
    required this.packageId,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      bookableType: _parseBookableType(json['bookable_type']),
      bookableId: json['bookable_id'],
      bookingDate: json['booking_date'] ?? '',
      status: json['status'] ?? 'pending',
      packageBookingId: json['package_booking_id'],
      packageId: json['package_id'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
