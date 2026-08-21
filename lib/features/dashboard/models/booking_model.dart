class BookingModel {
  final int id;
  final String bookableType;
  final int bookableId;
  final String? bookingDate;
  final String? startDate;
  final String? endDate;
  final String status;

  BookingModel({
    required this.id,
    required this.bookableType,
    required this.bookableId,
    this.bookingDate,
    this.startDate,
    this.endDate,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      bookableType: json['bookable_type'] ?? '',
      bookableId: json['bookable_id'],
      bookingDate: json['booking_date'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'] ?? '',
    );
  }

  // "App\Models\HotelRoom" -> "Hotel"، للعرض بس
  String get typeLabel {
    final shortName = bookableType.split('\\').last;
    switch (shortName) {
      case 'HotelRoom':
        return 'Hotel';
      case 'FlightSchedule':
        return 'Flight';
      default:
        return shortName;
    }
  }
}
