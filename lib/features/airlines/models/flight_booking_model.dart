class FlightBookingModel {
  final int id;
  final int userId;
  final String bookingDate;
  final String status;
  final int bookableId;
  final String bookableType;
  final String createdAt;
  final String updatedAt;

  const FlightBookingModel({
    required this.id,
    required this.userId,
    required this.bookingDate,
    required this.status,
    required this.bookableId,
    required this.bookableType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlightBookingModel.fromJson(Map<String, dynamic> json) {
    return FlightBookingModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      bookingDate: json['booking_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      bookableId: json['bookable_id'] as int,
      bookableType: json['bookable_type']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
